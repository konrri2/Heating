//
//  ThermostatsManager.swift
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
    var roomsNames: [String] = ["main bedroom", "bathroom", "gust", "agata's", "leo's", "living room", "kitchen", "office"]
    var lastResul: [Thermostat]?
    
    let config: Config
    
    init() {
        config = ConfigManager.parseConfig()
    }
    
    
    static func debug_loadCsvLine(url: URL) -> Observable<[String]> {
        return Observable.just(url)
            .flatMap { url -> Observable<Data> in
                let request = URLRequest(url: url)
                return URLSession.shared.rx.data(request: request)
            }.map { data -> [String] in
                let dataStr = String(data: data, encoding: String.Encoding.utf8)
                guard let dataRow = dataStr else { return [] }
                let strArr = dataRow.components(separatedBy: ",")
                return strArr
            }
    }
    
    //TODO: change [Thermostat] into a model
    fileprivate func buildMeasurment(_ strArr: [String]) -> [Thermostat] {
        var retList = [Thermostat]()
        //date format 2019-08-12 10:45
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = dateFormatter.date(from: strArr[0])
        
        let oudsideTemp = Double(strArr[1].trimmingCharacters(in: .whitespaces))
        for (index, element) in self.roomsNames.enumerated() {
            let temp = Double(strArr[index+4].trimmingCharacters(in: .whitespaces))
            let setTemp = self.parseTemperature(strArr[index+13])
            
            let on = Bool(strArr[index+22].trimmingCharacters(in: .whitespaces).lowercased())
            
            let thermostat = Thermostat(
                roomName: element,
                timestamp: date,
                oudsideTemp: oudsideTemp,
                temperature: temp,
                setTemperature: setTemp,
                isOn: on,
                mode: strArr[index+31]
            )
            retList.append(thermostat)
        }
        self.lastResul = retList
        return retList
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
    func loadLastCsv() -> Observable<[Thermostat]> {
        guard let url = URL(string: config.lastMeasurementUrl) else {
            fatalError("\(config.lastMeasurementUrl) is not a correct url for heating system")
        }
        
        return Observable.just(url)
            .flatMap { url -> Observable<Data> in
                let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)  //it is important not to cache
                return URLSession.shared.rx.data(request: request)
            }.map { data -> [String] in
                let dataStr = String(data: data, encoding: String.Encoding.utf8)
                guard let dataRow = dataStr else { return [] }
                let strArr = dataRow.components(separatedBy: ",")
                return strArr
            }.map { strArr -> [Thermostat] in
                return self.buildMeasurment(strArr)
        }
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
    
    func loadAllCsv() -> Observable<MeasurementHistory> {
        guard let url = URL(string: config.allMeasurementsUrl) else {
            fatalError("\(config.lastMeasurementUrl) is not a correct url for heating system")
        }
        
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
                var retHistory = MeasurementHistory()
                for row in csvRows.dropFirst() {        //drop first because there is a header
                    let rowCells = row.components(separatedBy: ",")
                    if rowCells.count > 8 {
                        let measurment = self.buildMeasurment(rowCells)
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                        if let date = dateFormatter.date(from: rowCells[0]) {
                            retHistory[date] = measurment
                        }
                    }
                }
                return retHistory
            }

    }
    
    func loadHistoryCsv(for date: Date) {
        //TODO
        //TODO on server site
    }
}
