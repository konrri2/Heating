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
            cellView.frame = self.placeholderView.bounds //Works until screen rotation //TODO
            self.placeholderView.addSubview(cellView)
        } else {
            logError("cannot load nib")
        }
    }

    //calling loadAll each time is not optimal, but I set cachePolicy 5minutes
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
                                self.historyChartViewModel?.buildChart(for: roomName, chartView: self.lineChartView)
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            }
                        }
                    }
                }
        )  //if there is no subscription nathing will happend
        .disposed(by: disposeBag)
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSettings" {
            let controller = (segue.destination as! TempSettingVC)
            controller.theThermostatVM = self.theThermostatVM
            //do I need?   controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
}
