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
    let badNoHostServerMock: MockedBadNoHostServer = .init()
    let goodEndpointMock: MockedGoodEndpoint = .init(method: .get,
                                                     path: "players",
                                                     headers: nil,
                                                     encodingMethod: .queryString(queryItems: []))
    let badPathEndpointMock: MockedBadNoHostEndpoint = .init(method: .get,
                                                             path: "/players",
                                                             headers: nil,
                                                             encodingMethod: .queryString(queryItems: []))
    let goodJsonEncodingMock: MockedGoodJSONEncoding = .init()
    // swiftlint:disable:next force_unwrapping
    lazy var goodReachabilityMock: MockedReachabilityAdaptee = .init(server: goodServerMock)!
    lazy var goodHttpClient: HttpKit.Client<MockedGoodServer, MockedReachabilityAdaptee> = .init(server: goodServerMock,
                                                                                                 jsonEncoder: goodJsonEncodingMock,
                                                                                                 reachability: goodReachabilityMock)
    // swiftlint:disable:next force_unwrapping
    lazy var  badReachabilityMock: MockedReachabilityAdaptee = .init(server: badNoHostServerMock)!
    lazy var badNoHostHttpClient: HttpKit.Client<MockedBadNoHostServer, MockedReachabilityAdaptee> = .init(server: badNoHostServerMock,
                                                                                                           jsonEncoder: goodJsonEncodingMock,
                                                                                                           reachability: badReachabilityMock)

    func testUnauthorizedRequest() throws {
        let expectationUrlFail = XCTestExpectation(description: "Failed to construct URL")
        let closureWrapper: HttpKit.ClosureWrapper<MockedGoodEndpointResponse, MockedGoodServer> = .init({ result in
            XCTAssertNotNil(result.error)
            let nsError: NSError = .init(domain: "URLSession", code: 101, userInfo: nil)
            XCTAssertEqual(result.error, HttpKit.HttpError.httpFailure(error: nsError), "Not expected error")
            expectationUrlFail.fulfill()
        }, goodEndpointMock)
        let badNetBackendMock: MockedHTTPAdapteeWithFail<MockedGoodEndpointResponse, MockedGoodServer> = .init(.closure(closureWrapper))
        goodHttpClient.makeRxRequest(for: goodEndpointMock,
                                        withAccessToken: nil,
                                        transport: badNetBackendMock)
        wait(for: [expectationUrlFail], timeout: 1.0)
    }
    
    func testUrlConstruction() throws {
        let expectationUrlFail = XCTestExpectation(description: "Failed to construct URL")
        let closureWrapper: HttpKit.ClosureWrapper<MockedGoodEndpointResponse, MockedBadNoHostServer> = .init({ result in
            XCTAssertNotNil(result.error)
            XCTAssertEqual(result.error, HttpKit.HttpError.failedConstructUrl, "Not expected error")
            expectationUrlFail.fulfill()
        }, badPathEndpointMock)
        let badNetBackendMock: MockedHTTPAdapteeWithFail<MockedGoodEndpointResponse, MockedBadNoHostServer> = .init(.closure(closureWrapper))
        badNoHostHttpClient.makeRxRequest(for: badPathEndpointMock,
                                             withAccessToken: nil,
                                             transport: badNetBackendMock)
        wait(for: [expectationUrlFail], timeout: 0.5)
    }
}
