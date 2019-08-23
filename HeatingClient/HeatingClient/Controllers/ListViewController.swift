//
//  ViewController.swift
//  HeatingClient
//
//  Created by Konrad Leszczyński on 21/08/2019.
//  Copyright © 2019 Konrrisoft. All rights reserved.
//

import UIKit
import RxSwift

class ListViewController: UITableViewController {

    let disposeBag = DisposeBag()
    private var thermostatListVM: ThermostatListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        
        let conf = ConfigManager.parseConfig()
        populateThermostats(conf.HeatingSystemUrl)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.thermostatListVM == nil ? 0: self.thermostatListVM.thermostatsVM.count
    }
    
    private func populateThermostats(_ urlStr: String) {

        guard let url = URL(string: urlStr) else {
            fatalError("\(urlStr) is not a correct url for heating system")
        }
        let man = ThermostatsManager()
        man.loadLastCsv(url: url)
            .subscribe(onNext: { therArr in
                self.thermostatListVM = ThermostatListViewModel(therArr)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }).disposed(by: disposeBag)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ThermostatTableViewCell", for: indexPath) as? ThermostatTableViewCell else {
            fatalError("thermostatTableViewCell is not found")
        }
        
        let thermostatVM = self.thermostatListVM.thermostatAt(indexPath.row)
        cell.viewModel = thermostatVM

        return cell
    }
    
}
