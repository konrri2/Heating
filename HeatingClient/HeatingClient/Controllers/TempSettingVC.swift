//
//  TempSettingVC.swift
//  HeatingClient
//
//  Created by Konrad Leszczyński on 02/10/2019.
//  Copyright © 2019 Konrrisoft. All rights reserved.
//

import Foundation
import Charts
import RxSwift
import RxCocoa

class TempSettingVC: UIViewController {
    static var id = "TempSettingVC"
    
    @IBOutlet weak var chartView: LineChartView!

    let disposeBag = DisposeBag()
    var settingVM: SettingsViewModel?
    var theThermostatVM: ThermostatViewModel?
    var timeLabels: [String]?
    var lineChartDate: LineChartData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if chartView != nil {
            populateChart()
        }
    }
    
    internal func populateChart() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let man = SettingsManager()
        man.loadSettings()
            .subscribe(
                onNext: { roomsSettings in
                    if let error = roomsSettings.errorInfo {
                        logWarn(error)
                    }
                    else if roomsSettings.dict.isEmpty == false {
                        self.settingVM = SettingsViewModel(roomsSettings)
                        if let roomName = self.theThermostatVM?.thermostat.roomName {
                            if self.settingVM != nil {
                                (self.timeLabels, self.lineChartDate) = self.settingVM!.chartData(for: roomName, chartView: self.chartView)
                                //TODO: check if self can be nil if you navigate quickly
                                DispatchQueue.main.async {
                                    self.chartView.data = self.lineChartDate
                                    self.formatChartXAxis()
                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                }
                            }
                        }
                    }
                    
                }
        )
        .disposed(by: disposeBag)
    }
    
    private func formatChartXAxis() {
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        if let labels = timeLabels {
            xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
            xAxis.labelCount = labels.count
        }
    }
}
