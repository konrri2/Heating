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
        return Observable<UIColor>.just(ThermostatViewModel.textColor(for: thermostat.temperature))
    }
    
    var isOn: Observable<String> {
        if thermostat is RoomThermostat {
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
        } else {  //oudside
            return Observable<String>.just({
                var str = ""
                if let outTherm = thermostat as? OutsideVirtualThermostat {
                    if let desc = outTherm.weatherDescription {
                        if desc.contains("bezchmu") {
                            str = "☀️"
                        } else if desc.contains("niewidoczne") || desc.contains("pochmu") {
                            str = "☁️"
                        } else if desc.contains("descz") {
                            str = "🌧"
                        } else {
                            str = "🌤"
                        }
                    }
                }
                return str
                }())
        }
    }
    
    var setTemperature: Observable<String> {
        if thermostat is RoomThermostat {
            return Observable<String>.just("Set to \(thermostat.setTemperature ?? 0.0)")
        }
        else if thermostat is OutsideVirtualThermostat {
            return Observable<String>.just(
                {
                    var str = ""
                    if let outTherm = thermostat as? OutsideVirtualThermostat {
                        str = outTherm.weatherDescription ?? ""
                    }
                    return str
                }())
        } else if thermostat is CombiningVirtualThermostat {
            return Observable<String>.just( "select to show \n combined chart")
        } else {
            fatalError("unkonwn thermostat type")
        }
    }
    
    var setTemperatureColor: Observable<UIColor> {
        if thermostat is RoomThermostat {
            return Observable<UIColor>.just(ThermostatViewModel.textColor(for: thermostat.setTemperature))
        }
        else {
            return Observable<UIColor>.just(UIColor.black)
        }
    }
    
    var setBackgroundColor: Observable<UIColor> {
        if thermostat is RoomThermostat {
            var color = UIColor.white
            if #available(iOS 13.0, *) {
                //TODO install new xcode
                //color = UIColor.systemBackground
            }
            
            return Observable<UIColor>.just(color)
        }
        else {
            return Observable<UIColor>.just(UIColor.lightGray)
        }
    }
    
    ///arbitrarry choosen colors
    static func textColor(for temperature: Double?) -> UIColor {
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

