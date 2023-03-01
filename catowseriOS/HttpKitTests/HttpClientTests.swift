//
//  HttpClientTests.swift
//  HttpKitTests
//
//  Created by Andrei Ermoshin on 11/29/21.
//  Copyright © 2021 andreiermoshin. All rights reserved.
//

import XCTest
@testable import HttpKit
import Foundation

class HttpClientTests: XCTestCase {
    let goodServerMock: MockedGoodServer = .init()
    let goodEndpointMock: MockedGoodEndpoint = .init(httpMethod: .get,
                                                     path: "players",
                                                     headers: nil,
                                                     encodingMethod: .QueryString(items: .empty))
    let goodJsonEncodingMock: MockedGoodJSONEncoding = .init()
    // swiftlint:disable:next force_unwrapping
    lazy var goodReachabilityMock: MockedReachabilityAdaptee = .init(server: goodServerMock)!
    lazy var goodHttpClient = RestClient(server: goodServerMock,
                                         jsonEncoder: goodJsonEncodingMock,
                                         reachability: goodReachabilityMock)

    func testUnauthorizedRequest() throws {
        let expectationUrlFail = XCTestExpectation(description: "Failed to construct URL")
        let closureWrapper: ClosureWrapper<MockedGoodEndpointResponse, MockedGoodServer> = .init({ result in
            switch result {
            case .failure(let error):
                let nsError: NSError = .init(domain: "URLSession", code: 101, userInfo: nil)
                XCTAssertEqual(error, HttpError.httpFailure(error: nsError), "Not expected error")
                expectationUrlFail.fulfill()
            case .success:
                XCTFail("Expected to see an error")
            }
        }, goodEndpointMock)
        let badNetBackendMock: MockedHTTPAdapteeWithFail<MockedGoodEndpointResponse,
                                                         MockedGoodServer,
                                                         RxFreeInterface<MockedGoodEndpointResponse,
                                                                         MockedGoodServer>> = .init(.closure(closureWrapper))
        goodHttpClient.makeRxRequest(for: goodEndpointMock,
                                        withAccessToken: nil,
                                        transport: badNetBackendMock)
        wait(for: [expectationUrlFail], timeout: 1.0)
    }
}
