//
//  HostTests.swift
//  HostTests
//
//  Created by Andrei Ermoshin on 11/8/21.
//  Copyright © 2021 andreiermoshin. All rights reserved.
//

import XCTest
@testable import HttpKit

class HostTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitialization() throws {
        let wrongHostStringAsUrl = "http://example.com"
        let optionalBadHost1 = HttpKit.Host(rawValue: wrongHostStringAsUrl)
        let errStringHostFromUrl = "host name string should be in a form of an URL, it contains scheme"
        XCTAssertNil(optionalBadHost1, errStringHostFromUrl)
        
        // won't test all the bad cases for format, it should be done for a different type
        // which is used inside
        let wrongHostString2 = ".example.com"
        let optionalBadHost2 = HttpKit.Host(rawValue: wrongHostString2)
        let errStringHostFromBadStr = "host name string should have proper Domain Name format"
        XCTAssertNil(optionalBadHost2, errStringHostFromBadStr)
        
        if let badUrlForHost1 = URL(string: "http://192.168.0.1") {
            let optionalBadHost = HttpKit.Host(url: badUrlForHost1)
            XCTAssertNil(optionalBadHost, "Host ulr should't contain ip address")
        }
        
        if let normalUrlForHost1 = URL(string: "http://example.com") {
            let optionalHost = HttpKit.Host(url: normalUrlForHost1)
            XCTAssertNotNil(optionalHost, "Host object should be created when normal URL was provided")
        }
    }
    
    func testSecondLevelDomain() throws {
        if let normalUrlForHost1 = URL(string: "http://www.example.com") {
            let optionalHost = HttpKit.Host(url: normalUrlForHost1)
            XCTAssertNotNil(optionalHost, "Host object should be created when normal URL was provided")
            guard let host = optionalHost else {
                return
            }
            let errString = "Second level domain property returns not expected value"
            XCTAssertEqual(host.onlySecondLevelDomain, "example.com", errString)
        }
    }
}
