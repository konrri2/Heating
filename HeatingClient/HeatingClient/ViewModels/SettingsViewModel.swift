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

class SettingsViewModel {
    var roomsSettings: RoomsSettings
    let disposeBag = DisposeBag()
    var chartView: LineChartView?
    var roomName: String?
    
    var settingDayAt6 = 0.0
    
    init(_ rSetinngs: RoomsSettings) {
        self.roomsSettings = rSetinngs
    }
    
    public func buildChart(for roomName: String, chartView: LineChartView) {
        self.chartView = chartView
        self.roomName = roomName
        
        //setChartAppearance()
        
        self.setData()
        
        //scrollAndZoomChart()
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
        guard
            let rName = self.roomName,
            let roomS = roomsSettings.dict[rName]
            else {
                logError("there is no setting for room \(self.roomName ?? "[!!!! no name]")")
                return
        }
        
        let day6cde = ChartDataEntry(x: 6.0, y: roomS.tempDay6 ?? 0.0)
        let day22cde = ChartDataEntry(x: 21.90, y: roomS.tempDay22 ?? 0.0)
        let night22cde = ChartDataEntry(x: 22.10, y: roomS.tempNight22 ?? 0.0)
        let night6cde = ChartDataEntry(x: 30.0, y: roomS.tempNight6 ?? 0.0)
        
        let dayDataEntries = [day6cde, day22cde]
        let nightTempDataEntries = [night22cde, night6cde]
        
        let set1 = LineChartDataSet(entries: dayDataEntries, label: "old")
        let set2 = LineChartDataSet(entries: nightTempDataEntries, label: "old")
        
        let setDay6cde = ChartDataEntry(x: 6.0, y: settingDayAt6)
        let settDayEntries = [setDay6cde, day22cde]
        
        let set3 = LineChartDataSet(entries: settDayEntries, label: "new")
        let set4 = LineChartDataSet(entries: nightTempDataEntries, label: "new")
        
        
        set1.lineWidth = 2.0
        set1.setColor(UIColor.green)
        set2.setColor(.red)
        set2.lineWidth = 2.0
        
        let data = LineChartData(dataSets: [set2,set1, set4, set3])
        chartView?.data = data
    }
    
    @available(*, deprecated, message: "use build chart")
    func chartData(for roomName: String, chartView: LineChartView) -> ([String]?, LineChartData?) {
        var labels = Array(repeating: " ", count: 31)
        labels[6] = "6:00"
        labels[14] = "14:00"
        labels[22] = "22:00"
        labels[30] = "6:00"
        
        chartView.xAxis.axisMinimum = 5.0
        chartView.xAxis.axisMaximum = 31.0
        
        chartView.leftAxis.axisMinimum = 14
        chartView.leftAxis.axisMaximum = 26
        chartView.rightAxis.enabled = false
        
        guard let roomS = roomsSettings.dict[roomName] else {
            logError("there is no setting for room \(roomName)")
            return (nil, nil)
        }
        
        let day6cde = ChartDataEntry(x: 6.0, y: roomS.tempDay6 ?? 0.0)
        let day22cde = ChartDataEntry(x: 21.90, y: roomS.tempDay22 ?? 0.0)
        let night22cde = ChartDataEntry(x: 22.10, y: roomS.tempNight22 ?? 0.0)
        let night6cde = ChartDataEntry(x: 30.0, y: roomS.tempNight6 ?? 0.0)
        
        let dayDataEntries = [day6cde, day22cde]
        let nightTempDataEntries = [night22cde, night6cde]
        
        let set1 = LineChartDataSet(entries: dayDataEntries, label: "old")
        let set2 = LineChartDataSet(entries: nightTempDataEntries, label: "old")
        

        set1.lineWidth = 2.0
        set1.setColor(UIColor.green)
        set2.setColor(.red)
        set2.lineWidth = 2.0
        
        let data = LineChartData(dataSets: [set2,set1])
        
        return (labels, data)
    }
}
