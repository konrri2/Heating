//
//  HistoryChartViewModel.swift
//  HeatingClient
//
//  Created by Konrad Leszczyński on 27/09/2019.
//  Copyright © 2019 Konrrisoft. All rights reserved.
//

import Foundation
import Charts

typealias MeasurementHistory = [Date: [Thermostat]]

struct HistoryChartViewModel {
    var history: MeasurementHistory
    
    init(_ history: MeasurementHistory) {
        self.history = history
    }
    
    func chartData(for roomName: String) -> LineChartData {
        var dataEntries: [ChartDataEntry] = []

        var index: Double = 0
        for k in history.keys {
            if let arrThemostats = history[k],
                let therm = findThermostat(for: roomName, in: arrThemostats) {
                
                let dataEntry = ChartDataEntry(x: index, y: therm.temperature ?? 0.0)
                dataEntries.append(dataEntry)
                index += 1.0
            }
        }

        let chartDataSet = LineChartDataSet(entries: dataEntries, label: "test")
        let chartData = LineChartData(dataSet: chartDataSet)
        
        return chartData
    }
    
    private func findThermostat(for roomName: String, in thermostats: [Thermostat]) -> Thermostat? {
        var therm: Thermostat? = nil
        for t in thermostats {
            if t.roomName == roomName {
                therm = t
            }
        }
        return therm
    }
}
