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
        // just using some random header
        let header: HttpKit.HttpHeader = .accept(.html)
        let headers = [header]
        let endpointWithHeaders = MockedGoodEndpoint(method: .get,
                                                     path: path,
                                                     headers: headers,
                                                     encodingMethod: .httpBodyJSON(parameters: [:]))
        
        let possibleUrl = endpointWithHeaders.url(relatedTo: goodServer)
        XCTAssertNotNil(possibleUrl, "url method should return some url")
        if let url = possibleUrl {
            let urlRequest = try endpointWithHeaders.request(url, httpTimeout: 60, accessToken: nil)
            // Not entirely sure if we get same order every time
            var expectingHeaders = headers
            let additonalHeader: HttpKit.HttpHeader = .contentType(.json)
            expectingHeaders.append(additonalHeader)
            let errMsg = "Wrong set of headers in URLRequest"
            XCTAssertEqual(expectingHeaders.dictionary, urlRequest.allHTTPHeaderFields, errMsg)
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
\(goodServer.scheme)://\(goodServer.hostString)/\
\(minimumEndpoint.path)?\(queryItemName)=\(queryItemValue)
"""
            XCTAssertEqual(url1.absoluteString, expectedString, "Not expected url was generated")
        }
    }
    
    func testEndpointRequestAddParametersUsingJsonBody() throws {
        let key = "userId"
        let value = 1000
        let parameters: Parameters = [key: value]
        let endpoint = MockedGoodEndpoint(method: .get,
                                          path: path,
                                          headers: nil,
                                          encodingMethod: .httpBodyJSON(parameters: parameters))
        let possibleURL = endpoint.url(relatedTo: goodServer)
        XCTAssertNotNil(possibleURL, "url method should return some url")
        guard let url = possibleURL else {
            return
        }
        let interval: TimeInterval = 60
        let request = try endpoint.request(url, httpTimeout: interval, accessToken: nil)
        let goodSerializedData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        XCTAssertEqual(request.httpBody, goodSerializedData, "addParameters method serialized parameters with an error")
        
        let anotherParameters: Parameters = ["wrongKey": 22]
        let anotherData = try JSONSerialization.data(withJSONObject: anotherParameters, options: [])
        XCTAssertNotEqual(request.httpBody, anotherData, "addParameters method serialized parameters with an error")
    }
}
