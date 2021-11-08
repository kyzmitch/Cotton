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
        let wrongHostString = "http://example.com"
        let optionalBadDomainNameHost = HttpKit.Host(rawValue: wrongHostString)
        XCTAssertNil(optionalBadDomainNameHost)
    }
}
