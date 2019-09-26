//
//  HeatingClientTests.swift
//  HeatingClientTests
//
//  Created by Konrad Leszczyński on 06/09/2019.
//  Copyright © 2019 Konrrisoft. All rights reserved.
//

import XCTest
import RxSwift

@testable import HeatingClient

class HeatingClientTests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConfigManager() {
        let conf = ConfigManager.parseConfig()
        XCTAssertTrue(conf.HeatingSystemUrl.starts(with: "http"), "No http -> wrong url in config file")
    }
    
    func testJsonData() {
        let conf = ConfigManager.parseConfig()
        guard let url = URL(string: conf.HeatingSystemUrl) else {
            fatalError("\(conf.HeatingSystemUrl) is not a correct url for heating system")
        }
        let man = ThermostatsManager()
        let csvObserver = man.loadLastCsv(url: url)
            .subscribe(
                onNext: { thermostatsArr in
                    //does not enter here :-/
                    
                    XCTAssertEqual(thermostatsArr.count, 7, "number of thermostats must by 8")
            })
        XCTAssertNotNil(csvObserver, "man.loadLastCsv returns nil")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
