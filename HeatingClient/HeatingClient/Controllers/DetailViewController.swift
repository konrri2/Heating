//
//  DetailViewController.swift
//  HeatingClient
//
//  Created by Konrad Leszczyński on 26/09/2019.
//  Copyright © 2019 Konrrisoft. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Charts

class DetailViewController: UIViewController {

    static var id = "DetailViewController"
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    let disposeBag = DisposeBag()
    var historyChartViewModel: HistoryChartViewModel? = nil
    var theThermostatVM: ThermostatViewModel?
    var timeLabels: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if lineChartView != nil {
            populateChart()
        }
    }
    



    //TODO: calling loadAll each time is not optimal
    internal func populateChart() {
        let man = ThermostatsManager()
        man.loadAllCsv()
            .subscribe(
                onNext: { history in
                    self.historyChartViewModel = HistoryChartViewModel(history)
                    
                    DispatchQueue.main.async {
                        if let roomName = self.theThermostatVM?.thermostat.roomName {
                            (self.timeLabels, self.lineChartView.data) = self.historyChartViewModel!.chartData(for: roomName)
                            self.formatChart()
                            //reload or somthing TODO: check
                        }
                    }
                },
                onError: {error in
                    let alert = UIAlertController(title: "Network error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK :-(", style: UIAlertAction.Style.default, handler: nil))
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                }
        )  //if there is no subscription nathing will happend
        .disposed(by: disposeBag)
    }
    
    func formatChart() {
        // configure X axis
        let xAxis = lineChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false
        if let labels = timeLabels {
            xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
            xAxis.labelCount = labels.count
        }
        xAxis.labelRotationAngle = -90.0
        xAxis.granularity = 1.0
    }
    
    //MARK: - debug
    
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
    func showTestChart() {
        
        let unitsSold = [50.0, 25.0, 50.0, 75.0, 100.0, 75.0]

        setChart(dataPoints: months, values: unitsSold)
        
        
    }

    func setChart(dataPoints: [String], values: [Double]) {
        var dataEntries: [ChartDataEntry] = []

        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: values[i], data: dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry)
        }

        let chartDataSet = LineChartDataSet(entries: dataEntries, label: "test")
//        chartDataSet.circleRadius = 5
//        chartDataSet.circleHoleRadius = 2
//        chartDataSet.drawValuesEnabled = false

        let chartData = LineChartData(dataSets: [chartDataSet])


        lineChartView.data = chartData

        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: months)
//        lineChartView.xAxis.labelPosition = .bottom
//        lineChartView.xAxis.drawGridLinesEnabled = false
//        lineChartView.xAxis.avoidFirstLastClippingEnabled = true
//
//        lineChartView.rightAxis.drawAxisLineEnabled = false
//        lineChartView.rightAxis.drawLabelsEnabled = false
//
//        lineChartView.leftAxis.drawAxisLineEnabled = false
//        lineChartView.pinchZoomEnabled = false
//        lineChartView.doubleTapToZoomEnabled = false
//        lineChartView.legend.enabled = false
    }
}
