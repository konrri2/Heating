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


