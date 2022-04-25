//
//  HouseThermoState.swift
//  HeatingClient
//
//  Created by Konrad Leszczyński on 05/10/2019.
//  Copyright © 2019 Konrrisoft. All rights reserved.
//

import Foundation

struct HouseThermoState {
    var errorInfo: String?
    var array: [Thermostat]?
    var time: Date? //timestamp of the measurment
    
    //TOOD this shouldn't be harcoded
    let roomsNames: [String] = ["Main bedroom", "Bathroom", "Guest", "Agata's", "Leo's", "Living room", "Kitchen", "Office"]
    
//    init(_ arr: [Thermostat], _ timestamp: Date) {
//        self.array = arr
//        self.time = timestamp
//    }
    
    init(error: String) {
        errorInfo = error
    }
    
    init?(_ csvArr: [String])  {
        var strArr = csvArr

        var retList = [Thermostat]()
        var roomsOnly = [RoomThermostat]()
        //date format 2019-08-12 10:45
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        if let date = dateFormatter.date(from: strArr[0]) {
            self.time = date

            if Double(strArr[1].trimmingCharacters(in: .whitespaces)) == nil { // this happened when reading meteo had an error - must move/shift the whole array
                strArr.insert("-42", at: 1)
            }
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
                    isOn: on,
                    index: index
                )
                retList.append(thermostat)
                roomsOnly.append(thermostat)
            }
            let avgVirtualThermostat = CombiningVirtualThermostat(timestamp: date, toCombine: roomsOnly)
            retList.append(avgVirtualThermostat)
            
            self.array = retList
        }
        else {
            logWarn("HouseThermoState : Cennot parse date -> propably header in .csv")
            return nil
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
    
    subscript(index: Int) -> Thermostat? {
        get {
            return array?[index]
        }
    }
    
    func isNewer(_ other: HouseThermoState) -> Bool {
        if let time = self.time?.timeIntervalSince1970,
            let oTime = other.time?.timeIntervalSince1970 {
            return time > oTime
        }
        return false
    }
}
