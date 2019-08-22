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
    ///rooms names are copy-pasted from python server  //TODO should add API call to get this dynamically
    var roomsNames: [String] = ["main bedroom", "bathroom", "gust", "agata's", "leo's", "living room", "kitchen", "office"]
    var lastResul: [Thermostat]?
    
    static func loadCsvLine(url: URL) -> Observable<[String]> {
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
    func loadLastCsv(url: URL) -> Observable<[Thermostat]> {
        return Observable.just(url)
            .flatMap { url -> Observable<Data> in
                let request = URLRequest(url: url)
                return URLSession.shared.rx.data(request: request)
            }.map { data -> [String] in
                let dataStr = String(data: data, encoding: String.Encoding.utf8)
                guard let dataRow = dataStr else { return [] }
                let strArr = dataRow.components(separatedBy: ",")
                return strArr
            }.map { strArr -> [Thermostat] in
                var retList = [Thermostat]()
                //date format 2019-08-12 10:45
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                let date = dateFormatter.date(from: strArr[0])
                
                let oudsideTemp = Float(strArr[1].trimmingCharacters(in: .whitespaces))
                for (index, element) in self.roomsNames.enumerated() {
                    let temp = Float(strArr[index+4].trimmingCharacters(in: .whitespaces))
                    let setTemp = Float(strArr[index+13].trimmingCharacters(in: .whitespaces))
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
    }
}
