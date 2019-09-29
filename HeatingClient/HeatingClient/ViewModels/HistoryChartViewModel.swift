//
//  HistoryChartViewModel.swift
//  HeatingClient
//
//  Created by Konrad Leszczyński on 27/09/2019.
//  Copyright © 2019 Konrrisoft. All rights reserved.
//

import Foundation
import Charts

struct HistoryChartViewModel {
    var history: MeasurementHistory
    
    init(_ history: MeasurementHistory) {
        self.history = history
        logVerbose("number of Measurement in History = \(history.measurmentsArr?.count ?? -42)")
    }
    
    func chartData(for roomName: String) -> ([String]?, LineChartData?) {
        var dataEntries: [ChartDataEntry] = []
        var labels = [String]()
        
        var index: Double = 0
        guard let arr = history.measurmentsArr else {
            fatalError("history.measurmentsArr is empty")
        }
        for m in arr {
            if let arrThemostats = m.array,
                let therm = findThermostat(for: roomName, in: arrThemostats) {
                
                let dataEntry = ChartDataEntry(x: index, y: therm.temperature ?? 0.0)
                dataEntries.append(dataEntry)
                labels.append(formatTimeLabel(therm.timestamp))
                index += 1.0
            }
        }

        let chartDataSet = LineChartDataSet(entries: dataEntries, label: nil)
        let chartData = LineChartData(dataSet: chartDataSet)
        
        logVerbose("number of chart time labels = \(labels.count)")
        
        return (labels, chartData)
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
    
    private func formatTimeLabel(_ timestamp: Date?) -> String {
        guard let time = timestamp else {
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd HH:mm"
        return dateFormatter.string(from: time)
    }
}
