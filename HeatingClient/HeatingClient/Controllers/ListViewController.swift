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
    
    internal func populateThermostats(_ urlStr: String) {
        
        guard let url = URL(string: urlStr) else {
            fatalError("\(urlStr) is not a correct url for heating system")
        }
        let man = ThermostatsManager()
        man.loadLastCsv(url: url)
            .subscribe(
                onNext: { therArr in
                    self.thermostatListVM = ThermostatListViewModel(therArr)
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                },
                onError: {error in
                    let alert = UIAlertController(title: "Network error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK :-(", style: UIAlertAction.Style.default, handler: nil))
                    DispatchQueue.main.async {
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            ).disposed(by: disposeBag)
        
        //TODO only if succesfully downloaded last - try download all
        man.loadAllCsv()
            .subscribe()  //if there is no subscription nathing will happend
        .disposed(by: disposeBag)
    }
    
    //MARK: - TableView overrides
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.thermostatListVM == nil ? 0: self.thermostatListVM.thermostatsVM.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ThermostatTableViewCell", for: indexPath) as? ThermostatTableViewCell else {
            fatalError("ThermostatTableViewCell is not found")
        }
        
        let thermostatVM = self.thermostatListVM[indexPath.row]
        cell.viewModel = thermostatVM

        return cell
    }
    
    
    
    // MARK: - Segues
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "showDetail" {
             if let indexPath = tableView.indexPathForSelectedRow {
                 let object = thermostatListVM[indexPath.row]
                 let controller = (segue.destination as! DetailViewController)
                 controller.theThermostatVM = object
                 controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                 controller.navigationItem.leftItemsSupplementBackButton = true
             }
         }
     }
}
