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

    func testUrlCreationForEndpointWithoutPayload() throws {
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
    
    func testEndpointHeaders() throws {
        let header: HttpKit.HttpHeader = .accept(.html)
        let headers = [header]
        let endpointWithHeaders = MockedGoodEndpoint(method: .get,
                                                     path: path,
                                                     headers: headers,
                                                     encodingMethod: .httpBodyJSON(parameters: [:]))
        
        let url = endpointWithHeaders.url(relatedTo: goodServer)
        XCTAssertNotNil(url, "url method should return some url")
        if let url1 = url {
            let urlRequest = endpointWithHeaders.request(url1, httpTimeout: 60, accessToken: nil)
            XCTAssertEqual(headers.dictionary, urlRequest.allHTTPHeaderFields, "Wrong set of headers in URLRequest")
        }
    }
    
    func testUrlCreationEndpointWithQueryString() throws {
        let queryItemName = "client"
        let queryItemValue = "firefox"
        let queryItem = URLQueryItem(name: queryItemName, value: queryItemValue)
        let minimumEndpoint = MockedGoodEndpoint(method: .get,
                                                 path: path,
                                                 headers: nil,
                                                 encodingMethod: .queryString(queryItems: [queryItem]))
        let urlForMinimumEndpoint = minimumEndpoint.url(relatedTo: goodServer)
        XCTAssertNotNil(urlForMinimumEndpoint, "url method should return some url")
        if let url1 = urlForMinimumEndpoint {
            let expectedString = """
\(goodServer.scheme)://\(goodServer.hostString)/\(minimumEndpoint.path)?\(queryItemName)=\(queryItemValue)
"""
            XCTAssertEqual(url1.absoluteString, expectedString, "Not expected url was generated")
        }
    }
}
