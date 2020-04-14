import Foundation
import RxSwift
import RxCocoa

class ThermostatsManager {
    ///rooms names are copy-pasted from python server  //TODO should add API call to get names dynamically

    var lastDownloadTime: Date?
    var historyDownloadTime: Date?
    let config: Config
    
    static let shared = ThermostatsManager()
    
    private init() {
        config = ConfigManager.parseConfig()
    }
    
    
    //MARK: - public methods
    public func loadLastCsv() -> Observable<HouseThermoState> {
        logVerbose("loadLastCsv")
        guard let localUrl = URL(string: config.lastMeasurementUrl(local: true)) else {
            fatalError("config.lastMeasurementUrl(local: true): \(config.lastMeasurementUrl(local: true)) is not a correct url for heating system")
        }
        guard let remoteUrl = URL(string: config.lastMeasurementUrl(local: false)) else {
            fatalError("config.lastMeasurementUrl(local: true): \(config.lastMeasurementUrl(local: true)) is not a correct url for heating system")
        }
        
        let obsLocal = buildLastCsvObservable(for: localUrl)
        let obsRemote = buildLastCsvObservable(for: remoteUrl)

        return Observable
            .merge(obsLocal,obsRemote)
    }
    
    public func loadAllCsv() -> Observable<MeasurementHistory> {
        guard let localUrl = URL(string: config.allMeasurementsUrl(local: true)) else {
            fatalError("config.allMeasurementsUrl(local: is not a correct url for heating system")
        }
        guard let remoteUrl = URL(string: config.allMeasurementsUrl(local: false)) else {
            fatalError("config.allMeasurementsUrl(remote is not a correct url for heating system")
        }
        
        let obsLocal = buildAllCsvObservable(for: localUrl)
        let obsRemote = buildAllCsvObservable(for: remoteUrl)

        return Observable
            .merge(obsLocal,obsRemote)
    }
    
    public func isLastCsvUpToDate() -> Bool {
        guard let lastDownload = lastDownloadTime else {
            logVerbose("isUpToDate: firstDownload")
            return false
        }

        return ThermostatsManager.isDateRecent(lastDownload)
    }
    
    public func isHistoryUpToDate() -> Bool {
        guard let lastDownload = historyDownloadTime else {
            logVerbose("isUpToDate (historyDownloadTime): firstDownload")
            return false
        }
        let isRecent = ThermostatsManager.isDateRecent(lastDownload, timeMarginSec: 480)  //it compares to last data enty in csv, so it is always a few minutes old
        log("--++++++++---++++++++--  isHistoryUpToDate ---------------  ++++++++   last Download = \(lastDownload)    isRecent=\(isRecent)")
        return isRecent
    }
    
    static func isDateRecent_wrong(_ date: Date, timeMarginSec: Double = 60) -> Bool {
        let minutesAgo = Date().addingTimeInterval(-timeMarginSec)
        let minutesInFuture = Date().addingTimeInterval(timeMarginSec)
        let isRecent = date < minutesInFuture
        logVerbose("isUpToDate: lastDownload=\(date)   minutesAgo=\(minutesAgo)  minutesInFuture=\(minutesInFuture) return= \(isRecent)")
        return isRecent
    }
    
    static func isDateRecent(_ dateToCheck: Date, timeMarginSec: Double = 180) -> Bool {
        let now = Date()
        let dateWithMargin = dateToCheck.addingTimeInterval(timeMarginSec)
        let isRecent = dateWithMargin > now
        log("dateToCheck=\(dateToCheck)  now=\(now) dateWithMArgin=\(dateWithMargin) isRecent=\(isRecent)")
        
        return isRecent
    }
    
    //MARK: private methods
    
    /**
            /api/last return a single csv row with last measurments
     the CSV row has a specyfic format:
     date time,outside temp,weather,
     curr_temp,
     main bedroom,bathroom,gust,agata's,leo's',living room,kitchen,office,
     set_temp,
     main bedroom,bathroom,gust,agata's,leo's',living room,kitchen,office,
     is_on,
     main bedroom,bathroom,gust,agata's,leo's',living room,kitchen,office,
     mode,
     main bedroom,bathroom,gust,agata's,leo's',living room,kitchen,office

        */
    private func buildLastCsvObservable(for url: URL) -> Observable<HouseThermoState> {
        return Observable.just(url)
            .flatMap { url -> Observable<Data> in
                let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)  //it is important not to cache - because it thiks API is a static file. I check isUpToDate() when navigating and changing every second
                return URLSession.shared.rx.data(request: request)
            }.map { data -> [String] in
                let dataStr = String(data: data, encoding: String.Encoding.utf8)
                guard let dataRow = dataStr else { return [] }
                let strArr = dataRow.components(separatedBy: ",")
                return strArr
            }.map { strArr -> HouseThermoState in
                if let res = HouseThermoState(strArr) {
                    self.lastDownloadTime = res.time
                    log("--------------  lastDownlodedTime = \(self.lastDownloadTime)")
                    return res
                }
                else {
                    return HouseThermoState(error: "HouseThermoState returns nil for LastCsv")
                }
        }.catchErrorJustReturn(HouseThermoState(error: "==== error for url \(url.absoluteString) ===="))
    }
    

    
    private func buildAllCsvObservable(for url: URL) -> Observable<MeasurementHistory> {
        return Observable.just(url)
            .flatMap { url -> Observable<Data> in
                if self.isHistoryUpToDate() {  //caching mechanism things it is a static csv file, so I need to do manual checking
                    let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)// cachePolicy: .useProtocolCachePolicy, timeoutInterval: 300)
                    return URLSession.shared.rx.data(request: request)
                }
                else {  //if history download is old -> downlod without any caches
                    let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
                    return URLSession.shared.rx.data(request: request)
                }
                //this URLSessionConfiguration.default.urlCache = nil is not enough 
            }
            .map { data -> [String] in
                let dataStr = String(data: data, encoding: String.Encoding.utf8)
                guard let dataRow = dataStr else { return [] }
                let strArr = dataRow.components(separatedBy: "\n")
                return strArr
            }
            .map { csvRows -> MeasurementHistory in
                var measurmentsArr = [HouseThermoState]()
                for row in csvRows.dropFirst() {        //drop first because there is a header
                    let rowCells = row.components(separatedBy: ",")
                    if rowCells.count > 8 {
                        if let measurment = HouseThermoState(rowCells) {
                            measurmentsArr.append(measurment)
                        }
                    }
                }
                if let lastTempMeasurment = measurmentsArr.last {
                    self.historyDownloadTime = lastTempMeasurment.time
                    log("--------------  buildAllCsvObservable:historyDownloadTime = \(self.historyDownloadTime)")
                }
                
                return MeasurementHistory(measurmentsArr)
            }.catchErrorJustReturn(MeasurementHistory(error: "==== MeasurementHistory error for url \(url.absoluteString) ===="))

    }
}
