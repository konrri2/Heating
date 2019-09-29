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
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        }

        
        if lineChartView != nil {
            populateChart()
        }
        
        if let testView = Bundle.main.loadNibNamed(ThermostatTableViewCell.nibName, owner: self, options: nil)?.first as? UITableViewCell {
            testView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(testView)
//            NSLayoutConstraint.activate([
//                testView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
//                testView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
//                testView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
//                testView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
//                ])
            //self.testView = testView
        } else {
            logError("cannot load nib")
        }
    }
    



    //TODO: calling loadAll each time is not optimal
    internal func populateChart() {
        let man = ThermostatsManager()
        man.loadAllCsv()
            .subscribe(
                onNext: { history in
                    if let error = history.errorInfo {
                        logWarn(error)
                    }
                    else if let _ = history.measurmentsArr {
                        self.historyChartViewModel = HistoryChartViewModel(history)
                        
                        DispatchQueue.main.async {
                            if let roomName = self.theThermostatVM?.thermostat.roomName {
                                (self.timeLabels, self.lineChartDate) = self.historyChartViewModel!.chartData(for: roomName)
                                self.lineChartView.data = self.lineChartDate
                                self.formatChart()
                                //reload or somthing TODO: check
                            }
                        }
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
