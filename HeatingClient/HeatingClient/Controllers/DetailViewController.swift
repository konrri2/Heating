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
    @IBOutlet weak var placeholderView: UIView!
    
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
        
        if let cellView = Bundle.main.loadNibNamed(ThermostatTableViewCell.nibName, owner: self, options: nil)?.first as? ThermostatTableViewCell {
            cellView.viewModel = theThermostatVM
            self.placeholderView.addSubview(cellView)
            NSLayoutConstraint.activate([
                cellView.topAnchor.constraint(equalTo: self.placeholderView.topAnchor),
                cellView.leadingAnchor.constraint(equalTo: self.placeholderView.leadingAnchor),
                cellView.trailingAnchor.constraint(equalTo: self.placeholderView.trailingAnchor),
                cellView.bottomAnchor.constraint(equalTo: self.placeholderView.bottomAnchor),
                ])
        } else {
            logError("cannot load nib")
        }
    }
    



    //TODO: calling loadAll each time is not optimal
    internal func populateChart() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
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
                                (self.timeLabels, self.lineChartDate) = self.historyChartViewModel!.chartData(for: roomName, chartView: self.lineChartView)
                                self.lineChartView.data = self.lineChartDate
                                self.formatChartXAxis()
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                //reload or somthing TODO: check
                            }
                        }
                    }
                }
        )  //if there is no subscription nathing will happend
        .disposed(by: disposeBag)
    }
    
    func formatChartXAxis() {
        let xAxis = lineChartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.drawGridLinesEnabled = false
        if let labels = timeLabels {
            xAxis.valueFormatter = IndexAxisValueFormatter(values: labels)
            xAxis.labelCount = labels.count
        }
        xAxis.labelRotationAngle = -45.0
        xAxis.granularity = 1.0
      
        lineChartView.animate(yAxisDuration: 2)
    }
}
