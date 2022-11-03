//
//  SearchSuggestionsVMCombineTests.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 10/18/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import XCTest
@testable import CoreCatowser

final class SearchSuggestionsVMCombineTests: XCTestCase {
    private let rxSubscriber: HttpKitRxSubscriber = .init()
    private let subscriber: HttpKitSubscriber = .init()
    
    func testExample() throws {
        let restClient: RestInterfaceMock = .init()
        let contextMock: RestClientContextMock = .init(restClient, rxSubscriber, subscriber)
        let strategyMock: SearchAutocompleteStrategyMock = .init(contextMock)
    }

}
