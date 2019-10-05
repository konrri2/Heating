//
//  SettingsViewModel.swift
//  HeatingClient
//
//  Created by Konrad Leszczyński on 02/10/2019.
//  Copyright © 2019 Konrrisoft. All rights reserved.
//

import UIKit
import Charts
import RxSwift
import RxCocoa


class HouseSettingsViewModel {
    var roomsSettings: RoomsSettings
    
    init(_ rSetinngs: RoomsSettings) {
        self.roomsSettings = rSetinngs
    }
}

class RoomSettingsViewModel {
    let disposeBag = DisposeBag()
    var chartView: LineChartView?
    var theRoomSetting: RoomSetting
    
    //when the user starts changing in setting view
    var newSettings = [20.0, 20.0, 20.0, 20.0]
    
    init(_ rs: RoomSetting) {
        self.theRoomSetting = rs
        
        if let td6 = rs.tempDay6 {
            newSettings[0] = td6
        }
        if let td22 = rs.tempDay22 {
            newSettings[1] = td22
        }
        if let tn22 = rs.tempNight22 {
            newSettings[2] = tn22
        }
        if let tn6 = rs.tempNight6 {
            newSettings[3] = tn6
        }
    }

    public func buildChart(chartView: LineChartView) {
        self.chartView = chartView
        
        self.setData()

        formatXAxis()
        formatYAxis()
    }
    
    private func formatXAxis() {
        if let xAxis = chartView?.xAxis {
            xAxis.labelPosition = .bottom
            let labels = makeXLabels()
            xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
            xAxis.labelCount = labels.count
            
            xAxis.axisMinimum = 5.0
            xAxis.axisMaximum = 31.0
        }
    }
    
    private func formatYAxis() {
        chartView?.leftAxis.axisMinimum = 14
        chartView?.leftAxis.axisMaximum = 26
        chartView?.rightAxis.enabled = false
    }
    
    private func makeXLabels() -> [String] {
        var labels = Array(repeating: " ", count: 31)
        labels[6] = "6:00"
        labels[14] = "14:00"
        labels[22] = "22:00"
        labels[30] = "6:00"
        
        return labels
    }
    
    func setData() {
        let roomS = self.theRoomSetting

        let day6cde = ChartDataEntry(x: 6.0, y: roomS.tempDay6 ?? 0.0)
        let day22cde = ChartDataEntry(x: 21.90, y: roomS.tempDay22 ?? 0.0)
        let night22cde = ChartDataEntry(x: 22.10, y: roomS.tempNight22 ?? 0.0)
        let night6cde = ChartDataEntry(x: 30.0, y: roomS.tempNight6 ?? 0.0)
        
        let dayDataEntries = [day6cde, day22cde]
        let nightTempDataEntries = [night22cde, night6cde]
        
        let set1 = LineChartDataSet(entries: dayDataEntries, label: "old")
        let set2 = LineChartDataSet(entries: nightTempDataEntries, label: "old")
        
        let settings = self.newSettings
        let settDayEntries = [ChartDataEntry(x: 6.0, y: settings[0]), ChartDataEntry(x: 21.90, y: settings[1])]
        let settNightEntries = [ChartDataEntry(x: 22.10, y: settings[2]), ChartDataEntry(x: 30.0, y: settings[3])]
        
        let set3 = LineChartDataSet(entries: settDayEntries, label: "new")
        let set4 = LineChartDataSet(entries: settNightEntries, label: "new")
        
        
        set1.lineWidth = 2.0
        set1.setColor(UIColor.green)
        set2.setColor(.red)
        set2.lineWidth = 2.0
        
        let data = LineChartData(dataSets: [set2,set1, set4, set3])
        chartView?.data = data
    }
}
