//
//  HistoryChartViewModel.swift
//  HeatingClient
//
//  Created by Konrad Leszczyński on 27/09/2019.
//  Copyright © 2019 Konrrisoft. All rights reserved.
//

import Foundation
import Charts

public class DateValueFormatter: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()

    override init() {
        super.init()
        dateFormatter.dateFormat = "dd MMM \nHH:mm"
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}


class HistoryChartViewModel {
    var history: MeasurementHistory
    var chartView: LineChartView?
    var roomName: String?
    
    init(_ history: MeasurementHistory) {
        self.history = history
        if let count = history.measurmentsArr?.count {
            logVerbose("number of Measurement in History = \(count)")
            if count == 0 {
                logWarn("empty MeasurementHistory.measurmentsArr")
            }
        }
        else {
            logError("history.measurmentsArr? = nil")
        }
    }
    
    public func buildChart(for roomName: String, chartView: LineChartView) {
        self.chartView = chartView
        self.roomName = roomName
        
        setChartAppearance()
        
        self.setData()
                    
        scrollAndZoomChart()
    }
    
    func setData() {
        var values = [ChartDataEntry]()
        guard let arr = history.measurmentsArr,
                    roomName?.isEmpty == false
            else {
                fatalError("history.measurmentsArr is empty")
        }
        for m in arr {
            if let arrThemostats = m.array,
                let therm = findThermostat(for: roomName!, in: arrThemostats) {
                if let time = therm.timestamp?.timeIntervalSince1970,
                    let temp = therm.temperature {                      //if nill don't add data entry
                    let dataEntry = ChartDataEntry(x: time, y: temp)
                    values.append(dataEntry)
                }
            }
        }
        
        let set1 = LineChartDataSet(entries: values, label: "measurments")
        setTemperatureColors(set1)
        
        let data = LineChartData(dataSet: set1)
        data.setValueTextColor(.white)
        data.setValueFont(.systemFont(ofSize: 9, weight: .light))
        
        chartView?.data = data
    }
    
    fileprivate func scrollAndZoomChart() {
        let h: TimeInterval = 3600
        let day = h * 24.0
        let now = Date()
        //let cal = Calendar(identifier: .gregorian)
        //let midnightDate = cal.startOfDay(for: now)
        //let yesterdayMidnightDate = midnightDate.addingTimeInterval(-day)
        let yesterday = now.addingTimeInterval(-day)
        let referenceTimeInterval = yesterday.timeIntervalSince1970
        
        chartView?.setVisibleXRangeMaximum(day)
        if let axisDependency = chartView?.leftAxis.axisDependency {
            chartView?.setVisibleYRangeMaximum(12.0, axis: axisDependency)
            chartView?.moveViewTo(xValue: referenceTimeInterval, yValue: 20.0, axis: axisDependency)
        }
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

    //MARK: - appearance
    private func setChartAppearance() {
        if let chartView = self.chartView {
            chartView.chartDescription?.enabled = false
            chartView.dragEnabled = true
            chartView.setScaleEnabled(true)
            chartView.pinchZoomEnabled = false
            chartView.highlightPerDragEnabled = true
            chartView.backgroundColor = .white
            chartView.legend.enabled = false
            chartView.rightAxis.enabled = false
            chartView.legend.form = .line
            chartView.animate(xAxisDuration: 1.5)
            
            setXAxisAppearance()
            setYAxisAppearance()
        }
    }
    
    fileprivate func setTemperatureColors(_ set1: LineChartDataSet) {
        set1.axisDependency = .left
        set1.setColor(UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1))
        set1.lineWidth = 1.5
        set1.drawCirclesEnabled = false
        set1.drawValuesEnabled = false
        set1.fillAlpha = 0.26
        set1.fillColor = UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)
        set1.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        set1.drawCircleHoleEnabled = false
    }

    //MARK: - Axies appearance
    
    ///X axis in seconds since 1970 [timeinterval - double]
    fileprivate func setXAxisAppearance() {
        if let xAxis = chartView?.xAxis {
            xAxis.labelPosition = .topInside
            xAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
            let h: TimeInterval = 3600
            xAxis.drawAxisLineEnabled = true
            xAxis.drawGridLinesEnabled = true
            xAxis.granularityEnabled = true
            xAxis.labelCount = 7
            xAxis.granularity = h * 4.0
            
            xAxis.valueFormatter = DateValueFormatter()
        }
    }
    
    ///Y axis in degrees centigrades
    fileprivate func setYAxisAppearance() {
        if let leftAxis = self.chartView?.leftAxis {
            leftAxis.labelPosition = .insideChart
            leftAxis.labelFont = .systemFont(ofSize: 12, weight: .light)
            leftAxis.drawGridLinesEnabled = true
            leftAxis.granularityEnabled = true
            leftAxis.axisMinimum = -20
            leftAxis.axisMaximum = 40
            leftAxis.yOffset = -9  //so the tempertature labels will show slightly above lines
            //leftAxis.labelTextColor = UIColor(red: 255/255, green: 192/255, blue: 56/255, alpha: 1)
        }
    }
}
