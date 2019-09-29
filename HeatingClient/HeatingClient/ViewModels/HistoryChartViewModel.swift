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
    
    func chartData(for roomName: String, chartView: LineChartView) -> ([String]?, LineChartData?) {
        var temperatureDataEntries: [ChartDataEntry] = []
        var settingTempDataEntries: [ChartDataEntry] = []
        var labels = [String]()
        
        chartView.rightAxis.axisMinimum = 15
        chartView.leftAxis.axisMinimum = 15
        chartView.rightAxis.axisMaximum = 25
        chartView.leftAxis.axisMaximum = 25
        
        
        var index: Double = 0
        guard let arr = history.measurmentsArr else {
            fatalError("history.measurmentsArr is empty")
        }
        for m in arr {
            if let arrThemostats = m.array,
                let therm = findThermostat(for: roomName, in: arrThemostats) {
                
                let dataEntry = ChartDataEntry(x: index, y: therm.temperature ?? 0.0)
                let setDataEntry = ChartDataEntry(x: index, y: therm.setTemperature ?? 0.0)
                temperatureDataEntries.append(dataEntry)
                settingTempDataEntries.append(setDataEntry)
                labels.append(formatTimeLabel(therm.timestamp))
                index += 1.0
            }
        }

        let set1 = LineChartDataSet(entries: temperatureDataEntries, label: "Temperature")
        set1.axisDependency = .left
        set1.setColor(UIColor.green)
        set1.drawCirclesEnabled = false
        set1.lineWidth = 2
        set1.circleRadius = 3
        set1.fillAlpha = 0.4
        set1.drawFilledEnabled = true
        set1.fillColor = .green
        set1.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        set1.drawCircleHoleEnabled = false
        set1.fillFormatter = DefaultFillFormatter { _,_  -> CGFloat in
            return CGFloat(chartView.leftAxis.axisMinimum)
        }
        
        let set2 = LineChartDataSet(entries: settingTempDataEntries, label: "Setting")
        set2.axisDependency = .left
        set2.setColor(UIColor.red)
        set2.drawCirclesEnabled = false
        set2.lineWidth = 2
        set2.circleRadius = 3
        set2.fillAlpha = 0.6
        set2.drawFilledEnabled = true
        set2.fillColor = .red
        set2.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        set2.drawCircleHoleEnabled = false
        set2.fillFormatter = DefaultFillFormatter { _,_  -> CGFloat in
            return CGFloat(chartView.leftAxis.axisMinimum)
        }
        
        let data = LineChartData(dataSets: [ set2,set1])
        data.setDrawValues(false)
        
        logVerbose("number of chart time labels = \(labels.count)")
        
        return (labels, data)
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
