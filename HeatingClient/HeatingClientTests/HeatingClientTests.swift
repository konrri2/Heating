//
//  HeatingClientTests.swift
//  HeatingClientTests
//
//  Created by Konrad Leszczyński on 06/09/2019.
//  Copyright © 2019 Konrrisoft. All rights reserved.
//

import XCTest
import RxSwift
import RxBlocking

@testable import HeatingClient

class HeatingClientTests: XCTestCase {
    
    var disposeBag: DisposeBag!
    
    override func setUp() {
       disposeBag = DisposeBag()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConfigManager() {
        let conf = ConfigManager.parseConfig()
        XCTAssertTrue(conf.localAddress.starts(with: "http"), "No http -> wrong url in config file")
        XCTAssertTrue(conf.remoteAddress.starts(with: "http"), "No http -> wrong url in config file")
    }
    
    func testGetSettings() throws {
        let man = SettingsManager()
        let apiReturns = try man.loadSettings()
            .toBlocking()
            .toArray()
        XCTAssertNotEqual(apiReturns.count, 3, "number of models of thermostats cennot be 3")
        XCTAssertEqual(apiReturns.count, 2, "number of models of thermostats must by 2 (one from local one form remote)")
        let t0 = apiReturns[0]
        let t1 = apiReturns[1]
        
        XCTAssertTrue(((t0.errorInfo == nil) != (t1.errorInfo == nil)), "only one (local xor remote) may terurn error")
        let successResultDict = t0.dict.isEmpty ? t1.dict : t0.dict
        XCTAssertNotEqual(successResultDict.keys.count, 3, "number of settings cennot be 3")
        XCTAssertEqual(successResultDict.keys.count, 8, "number of thermostats must by 8")
    }
    
    func testJsonData_loadLastCsv() throws {
        let man = ThermostatsManager.shared
        log("testing loadLastCsv...")
        //TODO - when testing the app starts and stars another download manually
        //XCTAssertFalse(man.isLastCsvUpToDate(), "before download it cannot be up to date")
        let apiReturns = try man.loadLastCsv()
            .toBlocking()
            .toArray()
        XCTAssertNotEqual(apiReturns.count, 3, "number of models of thermostats cennot be 3")
        XCTAssertEqual(apiReturns.count, 2, "number of models of thermostats must by 2 (one from local one form remote)")
        let t0 = apiReturns[0]
        let t1 = apiReturns[1]
        
        //testing count
        XCTAssertTrue(((t0.errorInfo == nil) != (t1.errorInfo == nil)), "only one (local xor remote) may terurn error")
        let successResultArray = t0.array != nil ? t0.array : t1.array
        XCTAssertNotNil(successResultArray, "one must return corretct array")
        XCTAssertNotEqual(successResultArray?.count, 3, "number of thermostats cennot be 3")
        XCTAssertEqual(successResultArray?.count, 10, "number of thermostats must by 8 +1 virtual oudside +1 virtual average")
        
        //testing time of cache
        XCTAssertTrue(man.isLastCsvUpToDate(), "just after download should be up to date")
        if let time = successResultArray?.first?.timestamp {
            log("lastCsv download time = \(time)")
            XCTAssertTrue(ThermostatsManager.isDateRecent(time, timeMarginSec: 600), "downloaded date is old \(time)")
        }
        else {
            XCTFail("no time in thermostat")
        }
    }

    func testAllHistoryJsonData() throws {
        let man = ThermostatsManager.shared
        log("testing loadAllCsv...")
        XCTAssertFalse(man.isHistoryUpToDate(), "before download it cannot be up to date")
        let apiReturns = try man.loadAllCsv()
            .toBlocking()
            .toArray()
        XCTAssertNotEqual(apiReturns.count, 3, "number of models of thermostats cennot be 3")
        XCTAssertEqual(apiReturns.count, 2, "number of models of thermostats must by 2 (one from local one form remote)")
        let t0 = apiReturns[0]
        let t1 = apiReturns[1]
        
        //testing count
        XCTAssertTrue(((t0.errorInfo == nil) != (t1.errorInfo == nil)), "only one (local xor remote) may return error")
        let successResultArray = t0.measurmentsArr != nil ? t0.measurmentsArr : t1.measurmentsArr
        XCTAssertTrue(man.isHistoryUpToDate(), "just after download should be up to date")
        if let thermoState = successResultArray?.last {
            if let time = thermoState.time {
                log("allCsv download time = \(time)")
                //TODO why it is buforing
                XCTAssertTrue(ThermostatsManager.isDateRecent(time, timeMarginSec: 600), "downloaded date is old \(time)")
            }
            else {
                XCTFail("no time in thermostat")
            }
        }
        else {
            XCTFail("cennot get thermostate from mesurments array")
        }
    }
    
    func testDates() {
        let now = Date()
        XCTAssertTrue(ThermostatsManager.isDateRecent(now))
        XCTAssertTrue(ThermostatsManager.isDateRecent(now.addingTimeInterval(-60)))
        XCTAssertFalse(ThermostatsManager.isDateRecent(now.addingTimeInterval(-600)))
        
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
