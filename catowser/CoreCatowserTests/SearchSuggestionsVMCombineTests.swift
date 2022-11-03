//
//  SearchSuggestionsVMCombineTests.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 10/18/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import XCTest
@testable import CoreCatowser
import CoreHttpKit
import HttpKit
import ReactiveHttpKit
import ReactiveSwift
import BrowserNetworking

struct MockedGoodResponse: ResponseType {
    static var successCodes: [Int] {
        return [200]
    }
}

final class SearchSuggestionsVMCombineTests: XCTestCase {
    let goodServerMock: MockedGoodDnsServer = .init()
    let goodJsonEncodingMock: MockedGoodJSONEncoding = .init()
    // swiftlint:disable:next force_unwrapping
    lazy var reachabilityMock = NetworkReachabilityAdapterMock(server: goodServerMock)!
    typealias Observer = Signal<MockedGoodResponse, HttpError>.Observer
    typealias ObserverWrapper = RxObserverWrapper<MockedGoodResponse, MockedGoodDnsServer, Observer>
    private let subscriber: Sub<MockedGoodResponse, MockedGoodDnsServer> = .init()
    private let rxSubscriber: RxSubscriber<MockedGoodResponse, MockedGoodDnsServer, ObserverWrapper> = .init()
    
    func testWebSearchAutocomplete() throws {
        let restClient: RestInterfaceMock = .init(server: goodServerMock,
                                                  jsonEncoder: goodJsonEncodingMock,
                                                  reachability: reachabilityMock,
                                                  httpTimeout: 10)
        let contextMock = RestClientContextMock(restClient, rxSubscriber, subscriber)
        let strategyMock: SearchAutocompleteStrategyMock = .init(contextMock)
        
        let autoCompleteFacade: WebSearchAutocomplete = .init(strategyMock)
        let producer = autoCompleteFacade.rxFetchSuggestions("how to use")
        let expected = ["how to use Swift", "how to use Kotlin"]
        let expectationRxSuggestionFail = XCTestExpectation(description: "Suggestions were not received")
        producer.startWithResult { result in
            expectationRxSuggestionFail.fulfill()
            // swiftlint:disable:next force_try
            let received = try! result.get()
            XCTAssertEqual(received, expected)
        }
    }
}
