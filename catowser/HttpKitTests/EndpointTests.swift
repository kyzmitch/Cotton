//
//  EndpointTests.swift
//  HttpKitTests
//
//  Created by Andrei Ermoshin on 11/8/21.
//  Copyright © 2021 andreiermoshin. All rights reserved.
//

import XCTest
import Alamofire
@testable import HttpKit

class EndpointTests: XCTestCase {
    let path = "players"
    let goodServer = MockedGoodServer()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUrlCreationForMinimumEndpoint() throws {
        let minimumEndpoint = MockedGoodEndpoint(method: .get,
                                                 path: path,
                                                 headers: nil,
                                                 encodingMethod: .httpBodyJSON(parameters: [:]))
        let urlForMinimumEndpoint = minimumEndpoint.url(relatedTo: goodServer)
        XCTAssertNotNil(urlForMinimumEndpoint, "url method should return some url")
        if let url1 = urlForMinimumEndpoint {
            let expectedString = "\(goodServer.scheme)://\(goodServer.hostString)/\(minimumEndpoint.path)"
            XCTAssertEqual(url1.absoluteString, expectedString, "Not expected url was generated")
        }
    }
}
