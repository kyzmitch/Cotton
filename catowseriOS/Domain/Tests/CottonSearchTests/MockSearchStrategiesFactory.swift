//
//  MockSearchStrategiesFactory.swift
//  CottonSearchTests
//

import CottonSearch

final class MockSearchStrategiesFactory: SearchStrategiesFactoryProtocol {
    var googleDnsStrategy: MockDNSResolvingStrategy = MockDNSResolvingStrategy()
    var duckDuckGoStrategy: MockSearchAutocompleteStrategy = MockSearchAutocompleteStrategy()
    var googleSearchStrategyMock: MockSearchAutocompleteStrategy = MockSearchAutocompleteStrategy()

    private(set) var googleDnsCallCount = 0
    private(set) var duckDuckGoCallCount = 0
    private(set) var googleSearchCallCount = 0

    func googleDnsResolvingStrategy() -> any DNSResolvingStrategy {
        googleDnsCallCount += 1
        return googleDnsStrategy
    }

    func duckDuckGoSearchStrategy() -> any SearchAutocompleteStrategy {
        duckDuckGoCallCount += 1
        return duckDuckGoStrategy
    }

    func googleSearchStrategy() -> any SearchAutocompleteStrategy {
        googleSearchCallCount += 1
        return googleSearchStrategyMock
    }
}
