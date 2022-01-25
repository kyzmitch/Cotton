//
//  HttpClientTests.swift
//  HttpKitTests
//
//  Created by Andrei Ermoshin on 11/29/21.
//  Copyright © 2021 andreiermoshin. All rights reserved.
//

import XCTest
@testable import HttpKit

class HttpClientTests: XCTestCase {
    let goodServerMock: MockedGoodServer = .init()
    let goodEndpointMock: MockedGoodEndpoint = .init(method: .get, path: "players", headers: nil, encodingMethod: .queryString(queryItems: []))
    lazy var goodHttpClient: HttpKit.Client<MockedGoodServer> = .init(server: goodServerMock)

    func testUnauthorizedRequest() throws {
        
    }
}
