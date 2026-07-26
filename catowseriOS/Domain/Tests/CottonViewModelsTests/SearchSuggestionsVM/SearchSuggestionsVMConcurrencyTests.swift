//
//  SearchSuggestionsVMConcurrencyTests.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 1/8/23.
//  Copyright © 2023 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import XCTest
import CoreBrowser
import CottonRestKit
import Mockable
@testable import CottonViewModels

@MainActor
final class SearchSuggestionsVMConcurrencyTests: SearchSuggestionsVMFixture {
    func testVMInitAndSuggestionsFetch() async throws {
        let vm: SearchSuggestionsViewModelImpl = .init(autocompleteUseCaseMock, searchViewContextMock)
        XCTAssertEqual(vm.state, .waitingForQuery)
        let input1 = "g"
        let input2 = "o"
        let expected1 = ["google", "gmail"]
        let known1 = ["google.com", "gmail.com"]
        let expected2 = ["opennet com", "overwatch"]
        let known2 = ["opennet.com", "blizzard.com"]

        autocompleteUseCaseMock.executeHandler = { input in
            XCTAssertEqual(input.source, .google)
            switch input.query {
            case input1:
                return expected1
            case input2:
                return expected2
            default:
                XCTFail("Unexpected query: \(input.query)")
                return []
            }
        }
        given(searchViewContextMock)
            .webAutocompletionSourceValue.willReturn(.google)
            .knownDomainsStorage.willReturn(knownDomainsStorageMock)
        given(knownDomainsStorageMock)
            .domainNames(whereURLContains: .value(input1)).willReturn(known1)
            .domainNames(whereURLContains: .value(input2)).willReturn(known2)

        await vm.fetchSuggestions(input1)
        XCTAssertEqual(vm.state, .everythingLoaded(known1, expected1))

        await vm.fetchSuggestions(input2)
        XCTAssertEqual(vm.state, .everythingLoaded(known2, expected2))
    }

    func testSuggestionsFetchFailure() async throws {
        let vm: SearchSuggestionsViewModelImpl = .init(autocompleteUseCaseMock, searchViewContextMock)
        XCTAssertEqual(vm.state, .waitingForQuery)
        let input1 = "g"
        let known1 = ["google.com", "gmail.com"]

        let error1 = HttpError.httpFailure(error: EndpointHttpError())
        autocompleteUseCaseMock.executeHandler = { _ in
            throw error1
        }
        given(searchViewContextMock)
            .webAutocompletionSourceValue.willReturn(.google)
            .knownDomainsStorage.willReturn(knownDomainsStorageMock)
        given(knownDomainsStorageMock)
            .domainNames(whereURLContains: .value(input1)).willReturn(known1)

        await vm.fetchSuggestions(input1)
        XCTAssertEqual(vm.state, .everythingLoaded(known1, []))
    }
}
