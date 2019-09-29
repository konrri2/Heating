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
    var roomsNames: [String] = ["Main bedroom", "Bathroom", "Guest", "Agata's", "Leo's", "Living room", "Kitchen", "Office"]
    var lastResul: [Thermostat]?
    
    let config: Config
    
    init() {
        config = ConfigManager.parseConfig()
    }
    
    
    //MARK: - public methods
    func loadLastCsv() -> Observable<HauseThermostats> {
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
    
    func loadAllCsv() -> Observable<MeasurementHistory> {
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
    
    
    //MARK: private methods
    fileprivate func buildMeasurment(_ strArr: [String]) -> HauseThermostats {
        var retList = [Thermostat]()
        //date format 2019-08-12 10:45
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = dateFormatter.date(from: strArr[0])
        let oudsideTemp = Double(strArr[1].trimmingCharacters(in: .whitespaces))
        let outsideThermostat = OutsideVirtualThermostat(timestamp: date, oudsideTemp: oudsideTemp, weatherDescription: strArr[2])
        retList.append(outsideThermostat)
        
        for (index, element) in self.roomsNames.enumerated() {
            let temp = Double(strArr[index+4].trimmingCharacters(in: .whitespaces))
            let setTemp = self.parseTemperature(strArr[index+13])
            
            let on = Bool(strArr[index+22].trimmingCharacters(in: .whitespaces).lowercased())
            
            let thermostat = RoomThermostat(
                roomName: element,
                timestamp: date,
                temperature: temp,
                setTemperature: setTemp,
                isOn: on
            )
            retList.append(thermostat)
        }
        self.lastResul = retList
        return HauseThermostats(retList)
    }
    
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
    private func buildLastCsvObservable(for url: URL) -> Observable<HauseThermostats> {
        return Observable.just(url)
            .flatMap { url -> Observable<Data> in
                let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)  //it is important not to cache
                return URLSession.shared.rx.data(request: request)
            }.map { data -> [String] in
                let dataStr = String(data: data, encoding: String.Encoding.utf8)
                guard let dataRow = dataStr else { return [] }
                let strArr = dataRow.components(separatedBy: ",")
                return strArr
            }.map { strArr -> HauseThermostats in
                return self.buildMeasurment(strArr)
        }.catchErrorJustReturn(HauseThermostats(error: "==== error for url \(url.absoluteString) ===="))
    }
    
    private func parseTemperature(_ str: String) -> Double? {
        var retTemp = Double(str.trimmingCharacters(in: .whitespaces))
        if retTemp == nil {
            let arrStr = str.components(separatedBy: "->")  //-> indicates the temperature is changing. It looks good in .csv but complicate parsing process
            if arrStr.count > 1 {
                retTemp = Double(arrStr[1].trimmingCharacters(in: .whitespaces))
            }
        }
        
        return retTemp
    }
    
    private func buildAllCsvObservable(for url: URL) -> Observable<MeasurementHistory> {
        return Observable.just(url)
            .flatMap { url -> Observable<Data> in
                let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)  //it is important not to cache
                return URLSession.shared.rx.data(request: request)
            }
            .map { data -> [String] in
                let dataStr = String(data: data, encoding: String.Encoding.utf8)
                guard let dataRow = dataStr else { return [] }
                let strArr = dataRow.components(separatedBy: "\n")
                return strArr
            }
            .map { csvRows -> MeasurementHistory in
                var measurmentsArr = [HauseThermostats]()
                for row in csvRows.dropFirst() {        //drop first because there is a header
                    let rowCells = row.components(separatedBy: ",")
                    if rowCells.count > 8 {
                        let measurment = self.buildMeasurment(rowCells)
                        measurmentsArr.append(measurment)
//                        let dateFormatter = DateFormatter()
//                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
//                        if let date = dateFormatter.date(from: rowCells[0]) {
//                            retHistory[date] = measurment
//                        }
                    }
                }
                return MeasurementHistory(measurmentsArr)
            }.catchErrorJustReturn(MeasurementHistory(error: "==== MeasurementHistory error for url \(url.absoluteString) ===="))

    }
}
