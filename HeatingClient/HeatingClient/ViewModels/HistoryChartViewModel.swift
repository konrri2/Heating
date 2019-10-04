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
    private var _values: [TimeInterval] = [TimeInterval]()
    private var _valueCount: Int = 0
    
    @objc public var values: [TimeInterval]
    {
        get
        {
            return _values
        }
        set
        {
            _values = newValue
            _valueCount = _values.count
        }
    }
    
    override init() {
        super.init()
        dateFormatter.dateFormat = "dd MMM \nHH:mm"
    }
    
    @objc public init(values: [TimeInterval])
    {
        super.init()
        
        self.values = values
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}


//formater 2
class ChartXAxisFormatter: NSObject {
    private let dateFormatter = DateFormatter()
    fileprivate var referenceTimeInterval: TimeInterval?

    convenience init(referenceTimeInterval: TimeInterval) {
        self.init()
        self.referenceTimeInterval = referenceTimeInterval
        //dateFormatter.dateFormat = "dd MMM \nHH:mm"
         dateFormatter.dateStyle = .short
         dateFormatter.timeStyle = .short
         dateFormatter.locale = Locale.current
    }
}


extension ChartXAxisFormatter: IAxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard let referenceTimeInterval = referenceTimeInterval
        else {
            return ""
        }

        //let date = Date(timeIntervalSince1970: value * 3600 * 24 + referenceTimeInterval)
        let date = Date(timeIntervalSince1970: value)
        return dateFormatter.string(from: date)
    }

}


class HistoryChartViewModel {
    var history: MeasurementHistory
    var chartView: LineChartView?
    var roomName: String?
    
    init(_ history: MeasurementHistory) {
        self.history = history
        logVerbose("number of Measurement in History = \(history.measurmentsArr?.count ?? -42)")
    }
    

    
    public func buildChart(for roomName: String, chartView: LineChartView) {
        self.chartView = chartView
        self.roomName = roomName
        
        chartView.chartDescription?.enabled = false

        chartView.dragEnabled = true
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = false
        chartView.highlightPerDragEnabled = true

        chartView.backgroundColor = .white

        chartView.legend.enabled = false

        let xAxis = chartView.xAxis
        xAxis.labelPosition = .topInside
        xAxis.labelFont = .systemFont(ofSize: 10, weight: .light)
        setXLabels(xAxis)


        let leftAxis = chartView.leftAxis
        leftAxis.labelPosition = .insideChart
        leftAxis.labelFont = .systemFont(ofSize: 12, weight: .light)
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = true
        leftAxis.axisMinimum = 15
        leftAxis.axisMaximum = 26
        leftAxis.yOffset = -9  //so the tempertature labels will show slightly above lines
        //leftAxis.labelTextColor = UIColor(red: 255/255, green: 192/255, blue: 56/255, alpha: 1)

        chartView.rightAxis.enabled = false
        chartView.legend.form = .line
        chartView.animate(xAxisDuration: 1.5)
        
        self.setDataCount()
    }
    

    
    func setDataCount() {
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
        
        let set1 = LineChartDataSet(entries: values, label: "DataSet 1")
        set1.axisDependency = .left
        set1.setColor(UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1))
        set1.lineWidth = 1.5
        set1.drawCirclesEnabled = false
        set1.drawValuesEnabled = false
        set1.fillAlpha = 0.26
        set1.fillColor = UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)
        set1.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        set1.drawCircleHoleEnabled = false
        
        let data = LineChartData(dataSet: set1)
        data.setValueTextColor(.white)
        data.setValueFont(.systemFont(ofSize: 9, weight: .light))
        
        chartView?.data = data
        
        scrollZoomChart()
    }
    
    fileprivate func scrollZoomChart() {
        let h: TimeInterval = 3600
        let day = h * 24.0
        let now = Date()
        let cal = Calendar(identifier: .gregorian)
        let midnightDate = cal.startOfDay(for: now)
        let yesterdayMidnightDate = midnightDate.addingTimeInterval(-day)
        let yesterday = now.addingTimeInterval(-day)
        let referenceTimeInterval = yesterday.timeIntervalSince1970
        
        chartView?.setVisibleXRangeMaximum(day)
        chartView?.moveViewToX(referenceTimeInterval)
    }
    
    fileprivate func setXLabels(_ xAxis: XAxis) {
        let h: TimeInterval = 3600
        xAxis.drawAxisLineEnabled = true
        xAxis.drawGridLinesEnabled = true
        xAxis.granularityEnabled = true

        xAxis.labelCount = 7
        xAxis.granularity = h * 6.0
    
        xAxis.valueFormatter = DateValueFormatter()
    }
    
    fileprivate func setXLabelsAnotherStrangeExperimenrt(_ xAxis: XAxis) {
        let h: TimeInterval = 3600
        let date = Date()
        let cal = Calendar(identifier: .gregorian)
        let midnightDate = cal.startOfDay(for: date)
        let yesterdayMidnightDate = midnightDate.addingTimeInterval(-24 * h)
        let from = yesterdayMidnightDate.timeIntervalSince1970
        let referenceTimeInterval: TimeInterval = from

        let xValuesNumberFormatter = ChartXAxisFormatter(referenceTimeInterval: referenceTimeInterval)
        xAxis.valueFormatter = xValuesNumberFormatter
    }
    
    fileprivate func setXLabels_bedExperiment(_ xAxis: XAxis, hoursStep: Double = 6) {
        let h: TimeInterval = 3600
        let date = Date()
        let cal = Calendar(identifier: .gregorian)
        let midnightDate = cal.startOfDay(for: date)
        let yesterdayMidnightDate = midnightDate.addingTimeInterval(-24 * h)
        let from = yesterdayMidnightDate.timeIntervalSince1970
        let timeStep = hoursStep * h
        
        var labels = [TimeInterval]()
        for i in 0...7 {
            labels.append(from + (Double(i) * timeStep))
        }
        

        xAxis.valueFormatter = DateValueFormatter(values: labels)
    }
    
    fileprivate func setXLabels_forceLabelsCount(_ xAxis: XAxis) {
        let hourSeconds: TimeInterval = 3600
        let now = Date().timeIntervalSince1970
        let oneDayTimeInterval = TimeInterval(24*hourSeconds)
        let yesterday = Date().addingTimeInterval(-oneDayTimeInterval).timeIntervalSince1970

        let numberOfHoursYesterday = floor(yesterday / hourSeconds)
        let xFrom = numberOfHoursYesterday * hourSeconds
        let numberOfHoursToday = floor(now / hourSeconds)
        let xTo = numberOfHoursToday * hourSeconds
        
        //xAxis.labelTextColor = UIColor(red: 255/255, green: 192/255, blue: 56/255, alpha: 1)
//        xAxis.drawAxisLineEnabled = true
//        xAxis.drawGridLinesEnabled = true
//        xAxis.centerAxisLabelsEnabled = true

        xAxis.axisMinimum = xFrom
        xAxis.axisMaximum = xTo
        xAxis.setLabelCount(7, force: true)
        xAxis.granularity = hourSeconds
        xAxis.valueFormatter = DateValueFormatter()
    }
    
    @available(*, deprecated, message: "use buildChart()")
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
