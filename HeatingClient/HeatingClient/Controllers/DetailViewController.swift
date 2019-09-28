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
    var lineChartDate: LineChartData?
    
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
                            (self.timeLabels, self.lineChartDate) = self.historyChartViewModel!.chartData(for: roomName)
                            self.lineChartView.data = self.lineChartDate
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
}
