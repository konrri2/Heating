//
//  Thermostat.swift
//  NewsAppMVVM
//
//  Created by Konrad Leszczyński on 16/08/2019.
//  Copyright © 2019 Mohammad Azam. All rights reserved.
//

import Foundation


class Thermostat {
    var roomName: String?  // /api/last returns no description
    var timestamp: Date?
    var temperature: Double?  //nil if thermostat is offline
    var setTemperature: Double?
    var isOn: Bool?
}

class RoomThermostat: Thermostat {
    var mode: String? //TODO enum
    
    init(
        roomName: String?,
        timestamp: Date?,
        temperature: Double?,
        setTemperature: Double?,
        isOn: Bool?
        ) {
        super.init()
        self.roomName = roomName
        self.timestamp = timestamp
        self.temperature = temperature
        self.setTemperature = setTemperature
        self.isOn = isOn
    }
}

class OutsideVirtualThermostat: Thermostat {
    var weatherDescription: String?
    
    init(
        timestamp: Date?,
        oudsideTemp: Double?,
        weatherDescription: String?
        ) {
        super.init()
        self.roomName = "Outside"
        self.timestamp = timestamp
        self.temperature = oudsideTemp
        self.weatherDescription = weatherDescription
    }
}

struct HouseThermoState {
    var errorInfo: String?
    var array: [Thermostat]?
    var time: Date? //timestamp of the measurment
    
    init(_ arr: [Thermostat], _ timestamp: Date) {
        self.array = arr
        self.time = timestamp
    }
    init(error: String) {
        errorInfo = error
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

struct MeasurementHistory {
    var errorInfo: String?
    //var dict = [Date: [Thermostat]]()
    var measurmentsArr: [HouseThermoState]?
    
//    init(_ dict: [Date: [Thermostat]]) {
//        self.dict = dict
//    }
    
    init(_ arr: [HouseThermoState]) {
        measurmentsArr = arr.sorted(by: {
            $1.isNewer($0)
        })  //checkin if the next one $1 is newer than the previous one $0
    }
    
    init(error: String) {
        errorInfo = error
    }
//    
//    subscript(date: Date) -> [Thermostat]? {
//        get {
//            return dict[date]
//        }
//    }
}
