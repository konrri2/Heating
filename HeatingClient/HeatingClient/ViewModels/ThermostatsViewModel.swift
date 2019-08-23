//
//  ThermostatsViewModel.swift
//  NewsAppMVVM
//
//  Created by Konrad Leszczyński on 20/08/2019.
//  Copyright © 2019 Mohammad Azam. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


struct ThermostatListViewModel {
    let thermostatsVM: [ThermostatViewModel]
    
    init(_ thermostats: [Thermostat]) {
        self.thermostatsVM = thermostats.compactMap(ThermostatViewModel.init)
    }
    
    func thermostatAt(_ index: Int) -> ThermostatViewModel {
        return self.thermostatsVM[index]
    }
    
    subscript(index: Int) -> ThermostatViewModel {
        get {
            return self.thermostatsVM[index]
        }
    }
}

struct ThermostatViewModel {
    
    let thermostat: Thermostat
    
    init(_ thermostat: Thermostat) {
        self.thermostat = thermostat
    }
    
    var roomName: Observable<String> {
        return Observable<String>.just(thermostat.roomName ?? "no name")
    }
    
    var temperature: Observable<String> {
        return Observable<String>.just(String(thermostat.temperature ?? 0.0))
    }
    
    var temperatureColor: Observable<UIColor> {
        return Observable<UIColor>.just(colorForTemperature())
    }
    
    var isOn: Observable<String> {
        return Observable<String>.just(
            {
                var str = "off"
                if thermostat.isOn == true {
                    str = "on"
                    if let temp = thermostat.setTemperature,
                        let setTemp = thermostat.temperature {
                        if setTemp >= temp {
                            str = "🔥  on"
                        }
                    }
                }
                return str
            }())
    }
    
    ///arbitrarry choosen colors
    func colorForTemperature() -> UIColor {
        guard let temp = thermostat.temperature else {
            return UIColor.purple
        }
        if temp >= 23.0 {
            return UIColor.red
        }
        else if temp >= 21.0 {
            return UIColor.orange
        }
        else if temp <= 18.0 {
            return UIColor.blue
        }
        else {
            return UIColor.green
        }
    }
    
    
}

