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
}

struct ThermostatViewModel {
    
    let thermostat: Thermostat
    
    init(_ thermostat: Thermostat) {
        self.thermostat = thermostat
    }
    
    var title: Observable<String> {
        return Observable<String>.just(thermostat.roomName ?? "no name")
    }
    
    var description: Observable<Float> {
        return Observable<Float>.just(thermostat.temperature ?? 0.0)
    }
}

