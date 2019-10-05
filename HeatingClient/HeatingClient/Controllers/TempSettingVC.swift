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
    @IBOutlet weak var pickerView: UIPickerView!
    
    var pickerData: [[String]] = [[String]]()
    let disposeBag = DisposeBag()
    var settingVM: SettingsViewModel?
    var theThermostatVM: ThermostatViewModel?
    var lineChartDate: LineChartData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if chartView != nil {
            populateChart()
        }
    
        
        //test Observable.just([[1.5, 2.4, 3.0], [5.3, 8.0, 13.0], [1.21, 2.34]])
        Observable.just([buildRange(), buildRange(), buildRange(), buildRange()])
            .bind(to: pickerView.rx.items(adapter: PickerViewViewAdapter()))
            .disposed(by: disposeBag)
        
        pickerView.rx.modelSelected(Double.self)
            .subscribe(onNext: { models in
                logVerbose("picker choose: ")
                print(models)
                self.settingVM?.settings = models
                self.redrawTheChart()
            })
            .disposed(by: disposeBag)
    }
    
    ///numbers that can be set
    func buildRange() -> [Double] {
        var ret = [Double]()
        for i in stride(from: 29.0, to: 15.0, by: -0.5) {
            ret.append(i)
        }
        return ret
    }
    
    @available(*, deprecated, message: "use pickerview")
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
                //self.settingVM?.settingDayAt6 = val
                self.settingVM?.settings = [val, 0.0, 0.0, 0.0]
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


final class PickerViewViewAdapter
    : NSObject
    , UIPickerViewDataSource
    , UIPickerViewDelegate
    , RxPickerViewDataSourceType
, SectionedViewDataSourceType {
    typealias Element = [[CustomStringConvertible]]
    private var items: [[CustomStringConvertible]] = []
    
    func model(at indexPath: IndexPath) throws -> Any {
        return items[indexPath.section][indexPath.row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = items[component][row].description
        label.textColor = UIColor.orange
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, observedEvent: Event<Element>) {
        Binder(self) { (adapter, items) in
            adapter.items = items
            pickerView.reloadAllComponents()
            }.on(observedEvent)
    }
}



