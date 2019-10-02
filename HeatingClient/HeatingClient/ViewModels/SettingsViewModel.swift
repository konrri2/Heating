//
//  SettingsViewModel.swift
//  HeatingClient
//
//  Created by Konrad Leszczyński on 02/10/2019.
//  Copyright © 2019 Konrrisoft. All rights reserved.
//

import Foundation
import Charts

struct SettingsViewModel {
    var roomsSettings: RoomsSettings
    
    init(_ rSetinngs: RoomsSettings) {
        self.roomsSettings = rSetinngs
    }
    
    func chartData(for roomName: String, chartView: LineChartView) -> ([String]?, LineChartData?) {
        let labels = ["6:00", "22:00", "6:00"]
        
        chartView.rightAxis.axisMinimum = 15
        chartView.leftAxis.axisMinimum = 15
        chartView.rightAxis.axisMaximum = 25
        chartView.leftAxis.axisMaximum = 25
        
        guard let roomS = roomsSettings.dict[roomName] else {
            logError("there is no setting for room \(roomName)")
            return (nil, nil)
        }
        
        let day6cde = ChartDataEntry(x: 6.0, y: roomS.tempDay6 ?? 0.0)
        let day22cde = ChartDataEntry(x: 21.90, y: roomS.tempDay22 ?? 0.0)
        let night22cde = ChartDataEntry(x: 22.10, y: roomS.tempNight22 ?? 0.0)
        let night6cde = ChartDataEntry(x: 36.0, y: roomS.tempNight6 ?? 0.0)
        
        let dayDataEntries = [day6cde, day22cde]
        let nightTempDataEntries = [night22cde, night6cde]
        
        let set1 = LineChartDataSet(entries: dayDataEntries, label: "day")
        let set2 = LineChartDataSet(entries: nightTempDataEntries, label: "night")
        
        set1.fillColor = .green
        set2.fillColor = .red
        
        let data = LineChartData(dataSets: [set2,set1])
        logVerbose("number of chart time labels = \(labels.count)")
        
        return (labels, data)
    }
}
