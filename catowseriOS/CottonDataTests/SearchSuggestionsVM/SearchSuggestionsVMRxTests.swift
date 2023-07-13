//
//  SearchSuggestionsVMRxTests.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 1/8/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import XCTest
@testable import CottonData
import CottonBase
import HttpKit
import ReactiveHttpKit
import ReactiveSwift
import BrowserNetworking
import SwiftyMocky

final class SearchSuggestionsVMRxTests: SearchSuggestionsVMFixture {
    private var disposables: Array<Disposable>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        disposables = []
    }
    
    // swiftlint:disable:next function_body_length
    func testVMInitAndSuggestionsFetch() throws {
        let vm: SearchSuggestionsViewModelImpl = .init(strategyMock, searchViewContextMock)
        XCTAssertEqual(vm.state, .waitingForQuery)
        Given(searchViewContextMock, .appAsyncApiTypeValue(getter: .reactive))
        let input1 = "g"
        let input2 = "o"
        let expected1 = ["google", "gmail"]
        let known1 = ["google.com", "gmail.com"]
        let expected2 = ["opennet com", "overwatch"]
        let known2 = ["opennet.com", "blizzard.com"]
        let promiseValue1: SearchSuggestionsResponse = .init(input1, expected1)
        let responseProducer1: SignalProducer<SearchSuggestionsResponse, HttpError> = .init(value: promiseValue1)
        let promiseValue2: SearchSuggestionsResponse = .init(input2, expected2)
        let responseProducer2: SignalProducer<SearchSuggestionsResponse, HttpError> = .init(value: promiseValue2)
        fetchSuggestionsCounter = 4
        let expectation1 = XCTestExpectation(description: "Suggestions were not received v1")
        let expectation2 = XCTestExpectation(description: "Suggestions were not received v2")
        let disposable = vm.rxState.signal.observeValues { state in
            if self.fetchSuggestionsCounter == 4 {
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
        if let nonNilValue = disposable {
            disposables.append(nonNilValue)
        }
        
        Given(strategyMock, .suggestionsProducer(for: .value(input1), willProduce: { stubber in
            stubber.return(responseProducer1)
        }))
        Given(searchViewContextMock, .knownDomainsStorage(getter: knownDomainsStorageMock))
        Given(knownDomainsStorageMock, .domainNames(whereURLContains: .value(input1), willReturn: known1))
        vm.fetchSuggestions(input1)
        XCTAssertEqual(vm.state, .waitingForQuery)
        wait(for: [expectation1], timeout: 1)
        Given(strategyMock, .suggestionsProducer(for: .value(input2), willProduce: { stubber in
            stubber.return(responseProducer2)
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
        Given(searchViewContextMock, .appAsyncApiTypeValue(getter: .reactive))
        let input1 = "g"
        let known1 = ["google.com", "gmail.com"]
        let error1 = HttpError.httpFailure(error: EndpointHttpError())
        let responseProducer1: SignalProducer<SearchSuggestionsResponse, HttpError> = .init(error: error1)
        fetchSuggestionsCounter = 2
        let expectation1 = XCTestExpectation(description: "Suggestions were not received v1")
        let disposable = vm.rxState.signal.observeValues { state in
            if self.fetchSuggestionsCounter == 2 {
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
        if let nonNilValue = disposable {
            disposables.append(nonNilValue)
        }
        
        Given(strategyMock, .suggestionsProducer(for: .value(input1), willProduce: { stubber in
            stubber.return(responseProducer1)
        }))
        Given(searchViewContextMock, .knownDomainsStorage(getter: knownDomainsStorageMock))
        Given(knownDomainsStorageMock, .domainNames(whereURLContains: .value(input1), willReturn: known1))
        vm.fetchSuggestions(input1)
        XCTAssertEqual(vm.state, .waitingForQuery)
        wait(for: [expectation1], timeout: 1)
    }
}
