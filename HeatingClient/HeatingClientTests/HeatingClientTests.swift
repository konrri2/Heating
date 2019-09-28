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
    
    func testJsonData_loadLastCsv() throws {
        let man = ThermostatsManager()
        log("testing loadLastCsv...")
        let thermostatsArr = try man.loadLastCsv()
            .toBlocking()
            .first()
        XCTAssertNotEqual(thermostatsArr?.count, 3, "number of thermostats cennot be 3")
        XCTAssertEqual(thermostatsArr?.count, 8, "number of thermostats must by 8")
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
