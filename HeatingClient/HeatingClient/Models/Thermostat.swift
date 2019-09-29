//
//  Thermostat.swift
//  NewsAppMVVM
//
//  Created by Konrad Leszczyński on 16/08/2019.
//  Copyright © 2019 Mohammad Azam. All rights reserved.
//

import Foundation


struct Thermostat {
    var roomName: String?  // /api/last returns no description
    var timestamp: Date?
    var oudsideTemp: Double?
    var temperature: Double?  //nil if thermostat is offline
    var setTemperature: Double?
    var isOn: Bool?
    var mode: String? //TODO enum
}

struct Thermostats {
    var errorInfo: String?
    var array: [Thermostat]?
    
    init(_ arr: [Thermostat]) {
        array = arr
    }
    init(error: String) {
        errorInfo = error
    }
    
    subscript(index: Int) -> Thermostat? {
        get {
            return array?[index]
        }
    }
}
