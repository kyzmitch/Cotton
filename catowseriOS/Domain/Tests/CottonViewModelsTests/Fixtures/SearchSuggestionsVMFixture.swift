//
//  SearchSuggestionsVMFixture.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 1/8/23.
//  Copyright © 2023 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import XCTest
import CoreBrowser
import Mockable
@testable import CottonViewModels

/// A known state against which a test is running for search suggestions vm
@MainActor
class SearchSuggestionsVMFixture: XCTestCase {
    var searchViewContextMock: MockSearchViewContext!
    var knownDomainsStorageMock: MockKnownDomainsSource!
    var autocompleteUseCaseMock: MockFetchAutocompleteSuggestionsUseCase!

    override func setUp() async throws {
        searchViewContextMock = .init()
        knownDomainsStorageMock = .init()
        autocompleteUseCaseMock = .init()
    }
}
