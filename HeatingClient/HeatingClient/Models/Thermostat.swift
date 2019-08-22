//
//  Thermostat.swift
//  NewsAppMVVM
//
//  Created by Konrad Leszczyński on 16/08/2019.
//  Copyright © 2019 Mohammad Azam. All rights reserved.
//

import Foundation


struct Thermostat {
    var roomName: String?  // /api/last returns no description //TODO implement /api/all
    var timestamp: Date? //TODO date
    var oudsideTemp: Float?
    var temperature: Float?  //nil if thermostat is offline
    var setTemperature: Float?
    var isOn: Bool?
    var mode: String? //TODO enum
}
