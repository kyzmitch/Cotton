//
//  SearchSuggestionsVMCombineTests.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 11/4/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import XCTest
@testable import CoreCatowser
import CoreHttpKit
import HttpKit
import ReactiveHttpKit
import ReactiveSwift
import Combine
import BrowserNetworking
import SwiftyMocky

final class SearchSuggestionsVMCombineTests: XCTestCase {
    private var goodServerMock: MockedGoodDnsServer!
    private var goodJsonEncodingMock: MockedGoodJSONEncoding!
    private var reachabilityMock: NetworkReachabilityAdapterMock<MockedGoodDnsServer>!
    typealias Observer = Signal<MockedGoodResponse, HttpError>.Observer
    typealias ObserverWrapper = RxObserverWrapper<MockedGoodResponse, MockedGoodDnsServer, Observer>
    private var subscriber: Sub<MockedGoodResponse, MockedGoodDnsServer>!
    private var rxSubscriber: RxSubscriber<MockedGoodResponse, MockedGoodDnsServer, ObserverWrapper>!
    private var goodRestClient: RestInterfaceMock<MockedGoodDnsServer,
                                                  NetworkReachabilityAdapterMock<MockedGoodDnsServer>,
                                                  MockedGoodJSONEncoding>!
    private lazy var goodContextMock: RestClientContextMock = .init(goodRestClient, rxSubscriber, subscriber)
    private lazy var strategyMock: SearchAutocompleteStrategyMock = .init(goodContextMock)
    private var searchViewContextMock: SearchViewContextMock!
    private var knownDomainsStorageMock: KnownDomainsSourceMock!
    private var cancellables: Set<AnyCancellable>!
    
    private var combineFetchSuggestionsCounter = 0
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        cancellables = []
        goodServerMock = .init()
        goodJsonEncodingMock = .init()
        // swiftlint:disable:next force_unwrapping
        reachabilityMock = NetworkReachabilityAdapterMock(server: goodServerMock)!
        subscriber = .init()
        rxSubscriber = .init()
        goodRestClient = .init(server: goodServerMock,
                               jsonEncoder: goodJsonEncodingMock,
                               reachability: reachabilityMock,
                               httpTimeout: 10)
        goodContextMock = .init(goodRestClient, rxSubscriber, subscriber)
        searchViewContextMock = .init()
        knownDomainsStorageMock = .init()
        strategyMock = .init(goodContextMock)
        combineFetchSuggestionsCounter = 0
    }

    func testVMInitAndSuggestionsFetch() throws {
        let vm: SearchSuggestionsViewModelImpl = .init(strategyMock, searchViewContextMock)
        XCTAssertEqual(vm.state, .waitingForQuery)
        Given(searchViewContextMock, .appAsyncApiTypeValue(getter: .combine))
        let input1 = "g"
        let input2 = "o"
        let expected1 = ["google", "gmail"]
        let known1 = ["google.com", "gmail.com"]
        let expected2 = ["opennet com", "overwatch"]
        let known2 = ["opennet.com", "blizzard.com"]
        let promiseValue1: SearchSuggestionsResponse = .init(input1, expected1)
        let responsePublisher1: AnyPublisher<SearchSuggestionsResponse, HttpError> = Future
            .success(promiseValue1)
            .eraseToAnyPublisher()
        let promiseValue2: SearchSuggestionsResponse = .init(input2, expected2)
        let responsePublisher2: AnyPublisher<SearchSuggestionsResponse, HttpError> = Future
            .success(promiseValue2)
            .eraseToAnyPublisher()
        combineFetchSuggestionsCounter = 5
        let expectation1 = XCTestExpectation(description: "Suggestions were not received v1")
        let expectation2 = XCTestExpectation(description: "Suggestions were not received v2")
        let cancellable = vm.combineState.sink { state in
            if self.combineFetchSuggestionsCounter == 5 {
                XCTAssertEqual(state, .waitingForQuery)
                self.combineFetchSuggestionsCounter -= 1
            } else if self.combineFetchSuggestionsCounter == 4 {
                XCTAssertEqual(state, .knownDomainsLoaded(known1))
                self.combineFetchSuggestionsCounter -= 1
            } else if self.combineFetchSuggestionsCounter == 3 {
                XCTAssertEqual(state, .everythingLoaded(known1, expected1))
                self.combineFetchSuggestionsCounter -= 1
                expectation1.fulfill()
            } else if self.combineFetchSuggestionsCounter == 2 {
                XCTAssertEqual(state, .knownDomainsLoaded(known2))
                self.combineFetchSuggestionsCounter -= 1
            } else if self.combineFetchSuggestionsCounter == 1 {
                XCTAssertEqual(state, .everythingLoaded(known2, expected2))
                self.combineFetchSuggestionsCounter -= 1
                expectation2.fulfill()
            } else {
                XCTAssert(false, "Not expected state change")
            }
        }
        cancellables.insert(cancellable)
        
        Given(strategyMock, .suggestionsPublisher(for: .value(input1), willProduce: { stubber in
            stubber.return(responsePublisher1)
        }))
        Given(searchViewContextMock, .knownDomainsStorage(getter: knownDomainsStorageMock))
        Given(knownDomainsStorageMock, .domainNames(whereURLContains: .value(input1), willReturn: known1))
        vm.fetchSuggestions(input1)
        XCTAssertEqual(vm.state, .waitingForQuery)
        wait(for: [expectation1], timeout: 1)
        Given(strategyMock, .suggestionsPublisher(for: .value(input2), willProduce: { stubber in
            stubber.return(responsePublisher2)
        }))
        Given(searchViewContextMock, .knownDomainsStorage(getter: knownDomainsStorageMock))
        Given(knownDomainsStorageMock, .domainNames(whereURLContains: .value(input2), willReturn: known2))
        vm.fetchSuggestions(input2)
        XCTAssertEqual(vm.state, .waitingForQuery)
        wait(for: [expectation2], timeout: 1)
    }

}
