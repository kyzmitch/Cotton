//
//  SearchSuggestionsVMFixture.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 1/8/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
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

/// A known state against which a test is running for search suggestions vm
class SearchSuggestionsVMFixture: XCTestCase {
    var goodServerMock: MockedGoodDnsServer!
    var goodJsonEncodingMock: MockedGoodJSONEncoding!
    var reachabilityMock: NetworkReachabilityAdapterMock<MockedGoodDnsServer>!
    typealias Observer = Signal<MockedGoodResponse, HttpError>.Observer
    typealias ObserverWrapper = RxObserverWrapper<MockedGoodResponse, MockedGoodDnsServer, Observer>
    var subscriber: Sub<MockedGoodResponse, MockedGoodDnsServer>!
    var rxSubscriber: RxSubscriber<MockedGoodResponse, MockedGoodDnsServer, ObserverWrapper>!
    var goodRestClient: RestInterfaceMock<MockedGoodDnsServer,
                                                  NetworkReachabilityAdapterMock<MockedGoodDnsServer>,
                                                  MockedGoodJSONEncoding>!
    lazy var goodContextMock: RestClientContextMock = .init(goodRestClient, rxSubscriber, subscriber)
    lazy var strategyMock: SearchAutocompleteStrategyMock = .init(goodContextMock)
    var searchViewContextMock: SearchViewContextMock!
    var knownDomainsStorageMock: KnownDomainsSourceMock!
    var fetchSuggestionsCounter = 0
    
    override func setUpWithError() throws {
        try super.setUpWithError()
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
        fetchSuggestionsCounter = 0
    }
}
