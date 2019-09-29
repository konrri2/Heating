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
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        let nib = UINib.init(nibName: "ThermostatTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: ThermostatTableViewCell.id)

        populateThermostats()
    }
    
    internal func populateThermostats() {
        let man = ThermostatsManager()
        man.loadLastCsv()
            .subscribe(
                onNext: { thermostats in
                    if let error = thermostats.errorInfo {
                        logWarn(error)
                    }
                    else if let therArr = thermostats.array {
                        self.thermostatListVM = ThermostatListViewModel(therArr)
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }

//                ,
//                onError: {error in
//TODO one always fail
//                    let alert = UIAlertController(title: "Network error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
//                    alert.addAction(UIAlertAction(title: "OK :-(", style: UIAlertAction.Style.default, handler: nil))
//                    DispatchQueue.main.async {
//                        self.present(alert, animated: true, completion: nil)
//                    }
//                }
            )
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
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ThermostatTableViewCell.id, for: indexPath) as? ThermostatTableViewCell else {
            fatalError("ThermostatTableViewCell is not found")
        }
        
        let thermostatVM = self.thermostatListVM[indexPath.row]
        cell.viewModel = thermostatVM

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetail", sender: indexPath);
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
