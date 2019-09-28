//
//  ThermostatTableViewCell.swift
//  HeatingClient
//
//  Created by Konrad Leszczyński on 22/08/2019.
//  Copyright © 2019 Konrrisoft. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class ThermostatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var setTemperatureLabel: UILabel!
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var isOnLabel: UILabel!
    
    static var id = "ThermostatTableViewCell"
    
    var disposeBag = DisposeBag()
    
    var viewModel: ThermostatViewModel? {
        didSet {
            if let vm = viewModel {
                vm.roomName
                    .bind(to: nameLabel.rx.text)
                    .disposed(by: disposeBag)
                vm.temperature
                    .bind(to: temperatureLabel.rx.text)
                    .disposed(by: disposeBag)

                vm.temperatureColor
                    .subscribe(onNext: { [weak self]  color in
                        self?.temperatureLabel.textColor = color
                    }).disposed(by: disposeBag)
                
                vm.isOn
                    .bind(to: isOnLabel.rx.text)
                    .disposed(by: disposeBag)
                
                vm.setTemperature
                    .bind(to: setTemperatureLabel.rx.text)
                    .disposed(by: disposeBag)
                
                vm.setTemperatureColor
                    .subscribe(onNext: { [weak self]  color in
                        self?.setTemperatureLabel.textColor = color
                    }).disposed(by: disposeBag)
            }
        }
    }
}
