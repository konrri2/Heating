//
//  MeasurementHistory.swift
//  HeatingClient
//
//  Created by Konrad Leszczyński on 05/10/2019.
//  Copyright © 2019 Konrrisoft. All rights reserved.
//

import Foundation

struct MeasurementHistory {
    var errorInfo: String?
    //var dict = [Date: [Thermostat]]()
    var measurmentsArr: [HouseThermoState]?
    
    init(_ arr: [HouseThermoState]) {
        measurmentsArr = arr.sorted(by: {
            $1.isNewer($0)
        })  //checkin if the next one $1 is newer than the previous one $0
    }
    
    init(error: String) {
        errorInfo = error
    }
}
