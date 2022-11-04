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
import SwiftyMocky

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
        let input = "how to use"
        let results = ["how to use Swift", "how to use Kotlin"]
        let searchSuggestionsResponse: SearchSuggestionsResponse = .init(input, results)
        typealias SuggestionProducer = SignalProducer<SearchSuggestionsResponse, HttpError>
        let responseProducer: SuggestionProducer = .init(value: searchSuggestionsResponse)
        Given(strategyMock, .suggestionsProducer(for: .value(input), willReturn: responseProducer))
        let autoCompleteFacade: WebSearchAutocomplete = .init(strategyMock)
        let producer = autoCompleteFacade.rxFetchSuggestions(input)
        let expectationRxSuggestionFail = XCTestExpectation(description: "Suggestions were not received")
        let disposable = producer.startWithResult { result in
            expectationRxSuggestionFail.fulfill()
            // swiftlint:disable:next force_try
            let received = try! result.get()
            XCTAssertEqual(received, results)
        }
        wait(for: [expectationRxSuggestionFail], timeout: 1)
    }
}
