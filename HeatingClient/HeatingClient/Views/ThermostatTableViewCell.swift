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
            }
        }
    }
}
