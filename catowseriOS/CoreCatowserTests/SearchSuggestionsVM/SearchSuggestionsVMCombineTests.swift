//
//  SearchSuggestionsVMCombineTests.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 11/4/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import XCTest
@testable import CoreCatowser
import CottonCoreBaseKit
import HttpKit
import ReactiveHttpKit
import ReactiveSwift
import Combine
import BrowserNetworking
import SwiftyMocky

final class SearchSuggestionsVMCombineTests: SearchSuggestionsVMFixture {
    private var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        cancellables = []
    }

    // swiftlint:disable:next function_body_length
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
        fetchSuggestionsCounter = 5
        let expectation1 = XCTestExpectation(description: "Suggestions were not received v1")
        let expectation2 = XCTestExpectation(description: "Suggestions were not received v2")
        let cancellable = vm.combineState.sink { state in
            if self.fetchSuggestionsCounter == 5 {
                XCTAssertEqual(state, .waitingForQuery)
                self.fetchSuggestionsCounter -= 1
            } else if self.fetchSuggestionsCounter == 4 {
                XCTAssertEqual(state, .knownDomainsLoaded(known1))
                self.fetchSuggestionsCounter -= 1
            } else if self.fetchSuggestionsCounter == 3 {
                XCTAssertEqual(state, .everythingLoaded(known1, expected1))
                self.fetchSuggestionsCounter -= 1
                expectation1.fulfill()
            } else if self.fetchSuggestionsCounter == 2 {
                XCTAssertEqual(state, .knownDomainsLoaded(known2))
                self.fetchSuggestionsCounter -= 1
            } else if self.fetchSuggestionsCounter == 1 {
                XCTAssertEqual(state, .everythingLoaded(known2, expected2))
                self.fetchSuggestionsCounter -= 1
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

    func testSuggestionsFetchFailure() throws {
        let vm: SearchSuggestionsViewModelImpl = .init(strategyMock, searchViewContextMock)
        XCTAssertEqual(vm.state, .waitingForQuery)
        Given(searchViewContextMock, .appAsyncApiTypeValue(getter: .combine))
        let input1 = "g"
        let known1 = ["google.com", "gmail.com"]
        let responsePublisher1: AnyPublisher<SearchSuggestionsResponse, HttpError> = Future
            .failure(HttpError.httpFailure(error: EndpointHttpError()))
            .eraseToAnyPublisher()
        fetchSuggestionsCounter = 3
        let expectation1 = XCTestExpectation(description: "Suggestions were not received v1")
        let cancellable = vm.combineState.sink { state in
            if self.fetchSuggestionsCounter == 3 {
                XCTAssertEqual(state, .waitingForQuery)
                self.fetchSuggestionsCounter -= 1
            } else if self.fetchSuggestionsCounter == 2 {
                XCTAssertEqual(state, .knownDomainsLoaded(known1))
                self.fetchSuggestionsCounter -= 1
            } else if self.fetchSuggestionsCounter == 1 {
                XCTAssertEqual(state, .everythingLoaded(known1, []), "Error's happened - suggestions are empty")
                self.fetchSuggestionsCounter -= 1
                expectation1.fulfill()
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
    }
}
