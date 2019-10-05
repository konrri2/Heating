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
    var theThermostatVM: ThermostatViewModel?
    var lineChartDate: LineChartData?
    var oneRoomSettingVM: RoomSettingsViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if chartView != nil {
            populateChart()
        }
    }
    
    //set only whan setting data is ready
    func setPickerView() {
        let optionsMatrix = [buildRange(), buildRange(), buildRange(), buildRange()]
        
        Observable.just(optionsMatrix)
            .bind(to: pickerView.rx.items(adapter: PickerViewViewAdapter()))
            .disposed(by: disposeBag)
        
        for (i, range) in optionsMatrix.enumerated() {
            if let setVal = oneRoomSettingVM?.newSettings[i],
                let index = range.firstIndex(of: setVal) {
                pickerView.selectRow(index, inComponent: i, animated: false)
            }
            else {
                pickerView.selectRow(10, inComponent: i, animated: false)  //if problem - set somwhare in the middle
            }
        }
        
        pickerView.rx.modelSelected(Double.self)
            .subscribe(onNext: { models in
                logVerbose("picker choose: ")
                print(models)
                self.oneRoomSettingVM?.newSettings = models
                self.redrawTheChart()
            })
            .disposed(by: disposeBag)
    }
    
    ///numbers that can be set
    private func buildRange() -> [Double] {
        var ret = [Double]()
        for i in stride(from: 29.0, to: 9.5, by: -0.5) {
            ret.append(i)
        }
        return ret
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
                        if let roomName = self.theThermostatVM?.thermostat.roomName,
                            let oneRoomSett = roomsSettings[roomName] {
                            self.oneRoomSettingVM = RoomSettingsViewModel(oneRoomSett)
                            self.redrawTheChart()
                            DispatchQueue.main.async {
                                self.setPickerView()
                            }
                        }
                    }
                    
                }
        )
        .disposed(by: disposeBag)
    }
    
    func redrawTheChart() {
        if self.oneRoomSettingVM != nil {
            logVerbose("redrawing settings chart")
            DispatchQueue.main.async {
                self.oneRoomSettingVM?.buildChart(chartView: self.chartView)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
        let val = items[component][row]
        label.text = val.description
        if let doubVal = val as? Double {
            label.textColor = ThermostatViewModel.textColor(for: doubVal)
        }
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



