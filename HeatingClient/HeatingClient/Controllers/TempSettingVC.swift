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
    @IBOutlet weak var steppersStackView: UIStackView!
    
    let disposeBag = DisposeBag()
    var settingVM: SettingsViewModel?
    var theThermostatVM: ThermostatViewModel?
    var lineChartDate: LineChartData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if chartView != nil {
            populateChart()
        }
        setSeteppers()
    }
    
    func setSeteppers() {
        if let stackView = steppersStackView {
            stackView.alignment = UIStackView.Alignment.fill
            
            let dayLabel = UILabel()
            dayLabel.text  = "  day   "

            let nightLabel = UILabel()
            nightLabel.text = "night  "
            
            let marginLabel = UILabel()
            marginLabel.text = " ℃"
            
            //stackView.addArrangedSubview(dayLabel)
            stackView.addArrangedSubview(buildStepper())
            stackView.addArrangedSubview(buildStepper())
            //stackView.addArrangedSubview(nightLabel)
            stackView.addArrangedSubview(buildStepper())
            stackView.addArrangedSubview(buildStepper())
            //stackView.addArrangedSubview(marginLabel)
        }
    }
    
    func buildStepper() -> UIStepper {
        let stepper = UIStepper()
        stepper.transform = CGAffineTransform.init(scaleX: 1.0, y: 0.6)
                                .translatedBy(x: 0, y: 70)
                                //.scaledBy(x: 0.6, y: 1.2)
                                .rotated(by: CGFloat(-Double.pi / 2.0))
        
        stepper.minimumValue = 10.0
        stepper.maximumValue = 28.0
        stepper.stepValue = 0.5
        stepper.value = 17.0
        
        
        stepper.rx.value.asObservable()
            .subscribe(onNext: {val in
                log("stepper.rx.value subscribe val=\(val)")
                self.settingVM?.settingDayAt6 = val
                self.redrawTheChart()
            })
            .disposed(by: disposeBag)
        
        return stepper
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
                        self.redrawTheChart()
                    }
                    
                }
        )
        .disposed(by: disposeBag)
    }
    
    func redrawTheChart() {
        if let roomName = self.theThermostatVM?.thermostat.roomName {
            if self.settingVM != nil {
                DispatchQueue.main.async {
                    self.settingVM?.buildChart(for: roomName, chartView: self.chartView)
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
        }
    }
}
