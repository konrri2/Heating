//
//  HauseThermostatsManager.swift
//  NewsAppMVVM
//
//  Created by Konrad Leszczyński on 16/08/2019.
//  Copyright © 2019 Mohammad Azam. All rights reserved.
//

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
        lastDownloadTime = Date()
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
    
    public func isUpToDate() -> Bool {
        guard let lastDownload = lastDownloadTime else {
            logVerbose("isUpToDate: firstDownload")
            return false
        }

        return ThermostatsManager.isDateRecent(lastDownload)
    }
    
    public func isHistoryUpTpDate() -> Bool {
        guard let lastDownload = historyDownloadTime else {
            logVerbose("isUpToDate: firstDownload")
            return false
        }
        
        return ThermostatsManager.isDateRecent(lastDownload)
    }
    
    static func isDateRecent(_ date: Date, timeMarginSec: Double = 60) -> Bool {
        let minutesAgo = Date().addingTimeInterval(-timeMarginSec)
        logVerbose("isUpToDate: lastDownload=\(date)   minutesAgo=\(minutesAgo)")
        return date > minutesAgo
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
                if self.isHistoryUpTpDate() {  //caching mechanism things it is a static csv file, so I need to do manual checking
                    let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 300)
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
                return MeasurementHistory(measurmentsArr)
            }.catchErrorJustReturn(MeasurementHistory(error: "==== MeasurementHistory error for url \(url.absoluteString) ===="))

    }
}
