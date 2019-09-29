//
//  HauseThermostatsViewModel.swift
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
        return Observable<UIColor>.just(textColor(for: thermostat.temperature))
    }
    
    var isOn: Observable<String> {
        return Observable<String>.just(
            {
                var str = "off"
                if thermostat.isOn == true {
                    str = "on"
                    if let setTemp = thermostat.setTemperature,
                        let temp = thermostat.temperature {
                        if setTemp >= temp {
                            str = "🔥  on"
                        }
                    }
                }
                return str
            }())
    }
    
    var setTemperature: Observable<String> {
        return Observable<String>.just("Set to \(thermostat.setTemperature ?? 0.0)")
    }
    
    var setTemperatureColor: Observable<UIColor> {
        return Observable<UIColor>.just(textColor(for: thermostat.setTemperature))
    }
    
    ///arbitrarry choosen colors
    func textColor(for temperature: Double?) -> UIColor {
        guard let temp = temperature else {
            return UIColor.purple
        }
        if temp >= 23.0 {
            return UIColor.red
        }
        else if temp >= 21.0 {
            return UIColor.orange
        }
        else if temp <= 16.0 {
            return UIColor.blue
        }
        else if temp <= 18.0 {
            return UIColor.cyan
        }
        else {
            return UIColor.green  //just right
        }
    }
    
    
}

