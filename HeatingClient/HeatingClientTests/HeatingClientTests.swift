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
        let man = ThermostatsManager()
        log("testing loadLastCsv...")
        let apiReturns = try man.loadLastCsv()
            .toBlocking()
            .toArray()
        XCTAssertNotEqual(apiReturns.count, 3, "number of models of thermostats cennot be 3")
        XCTAssertEqual(apiReturns.count, 2, "number of models of thermostats must by 2 (one from local one form remote)")
        let t0 = apiReturns[0]
        let t1 = apiReturns[1]
        
        XCTAssertTrue(((t0.errorInfo == nil) != (t1.errorInfo == nil)), "only one (local xor remote) may terurn error")
        let successResultArray = t0.array != nil ? t0.array : t1.array
        XCTAssertNotNil(successResultArray, "one must return corretct array")
        XCTAssertNotEqual(successResultArray?.count, 3, "number of thermostats cennot be 3")
        XCTAssertEqual(successResultArray?.count, 8, "number of thermostats must by 8")
    }

    func testAllHistoryJsonData() throws {
        let man = ThermostatsManager()
        log("testing loadAllCsv...")
        let measurmentsDict = try man.loadAllCsv()
            .toBlocking()
            .first()
        let thermostatsArr = measurmentsDict?.values.first
        XCTAssertNotEqual(thermostatsArr?.count, 3, "number of thermostats cennot be 3")
        XCTAssertEqual(thermostatsArr?.count, 8, "number of thermostats must by 8")
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
