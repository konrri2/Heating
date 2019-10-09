//
//  ViewController.swift
//  HeatingClient
//
//  Created by Konrad Leszczyński on 21/08/2019.
//  Copyright © 2019 Konrrisoft. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ListViewController: UITableViewController {

    let disposeBag = DisposeBag()
    private var thermostatListVM: ThermostatListViewModel!
    private var thermostatsManager: ThermostatsManager?
    
    ///Error infos. If both urls have error message -> show error alert. but check if it is not the same error for the same url
    private var errorHouseStates: BehaviorRelay<[String]> = BehaviorRelay(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        let nib = UINib.init(nibName: "ThermostatTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: ThermostatTableViewCell.id)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        self.tableView.tableFooterView = UIView()
        
        thermostatsManager = ThermostatsManager.shared
        observeErrors()
        
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForegroundNotified(_:)),
            name: UIApplication.willEnterForegroundNotification,
            object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func observeErrors() {
        errorHouseStates.subscribe(onNext: {
            [unowned self] errorArr in
            let count = errorArr.count
            logWarn("======   num of wrong houseThermoStates = \(count)")
            if (count >= 2) {
                let alert = UIAlertController(title: "Connection error", message: "Both HouseThermoStates are wrong", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
        .disposed(by: disposeBag)
    }
    
    @objc func appWillEnterForegroundNotified(_ notification: Notification!) {
        logVerbose("appWillEnterForegroundNotified")
        if thermostatsManager?.isLastCsvUpToDate() == false {
            populateThermostats()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logVerbose("viewDidAppear")
        if thermostatsManager?.isLastCsvUpToDate() == false {
            populateThermostats()
        }
    }
    
    @objc func refresh(sender:AnyObject) {
        logVerbose("=--------------    @objc private func refreshData(_ sender: Any)")
        populateThermostats()
    }
    
    internal func populateThermostats() {
        logVerbose("populateThermostats")
        DispatchQueue.main.async {  //TODO make it work
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        if let man = thermostatsManager {
            man.loadLastCsv()
                .subscribe(
                    onNext: {
                        [unowned self] thermostats in
                        if let error = thermostats.errorInfo {
                            logWarn(error)
                            if self.errorHouseStates.value.contains(error) {
                                log("we already know that from this url there is an error")
                            } else {
                                let newArr = self.errorHouseStates.value + [error]
                                self.errorHouseStates.accept(newArr)
                            }
                        }
                        else if let therArr = thermostats.array {
                            self.thermostatListVM = ThermostatListViewModel(therArr)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.refreshControl?.endRefreshing()
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            }
                        }
                    }
                )
                .disposed(by: disposeBag)
        }
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
                 // why? controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                 controller.navigationItem.leftItemsSupplementBackButton = true
             }
         }
     }
}
