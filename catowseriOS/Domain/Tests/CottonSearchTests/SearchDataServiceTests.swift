//
//  SearchDataServiceTests.swift
//  CottonSearchTests
//

import Combine
import CoreBrowser
import CottonDependencyAssembly
import CottonRestKit
import Foundation
import GenericServiceKit
import Testing
@testable import CottonSearch

private final class ResultBox<T>: @unchecked Sendable {
    var value: T?
}

struct SearchDataServiceTests {

    private let queue = ImmediateDispatchQueue()

    // MARK: - Autocomplete

    @Test func fetchAutocompleteSuggestionsUsesGoogleStrategy() throws {
        let factory = MockSearchStrategiesFactory()
        factory.googleSearchStrategyMock.publisherHandler = { query in
            Just(SearchSuggestionsResponse(query, ["\(query)1", "\(query)2"]))
                .setFailureType(to: HttpError.self)
                .eraseToAnyPublisher()
        }
        let service = makeService(factory: factory)
        let command = SearchServiceCommand.fetchAutocompleteSuggestions(UUID(), .google, "cat")
        let box = ResultBox<Result<SearchServiceData, SearchServiceError>>()

        service.sendCommand(command, nil) { box.value = $0 }

        #expect(factory.googleSearchCallCount == 1)
        #expect(factory.duckDuckGoCallCount == 0)
        #expect(factory.googleSearchStrategyMock.publisherCalls == ["cat"])
        let result = try #require(box.value)
        let data = try result.get()
        let suggestions = try data.suggestions
        #expect(suggestions == ["cat1", "cat2"])
    }

    @Test func fetchAutocompleteSuggestionsUsesDuckDuckGoStrategy() throws {
        let factory = MockSearchStrategiesFactory()
        factory.duckDuckGoStrategy.publisherHandler = { query in
            Just(SearchSuggestionsResponse(query, ["ddg-\(query)"]))
                .setFailureType(to: HttpError.self)
                .eraseToAnyPublisher()
        }
        let service = makeService(factory: factory)
        let command = SearchServiceCommand.fetchAutocompleteSuggestions(UUID(), .duckduckgo, "swift")
        let box = ResultBox<Result<SearchServiceData, SearchServiceError>>()

        service.sendCommand(command, nil) { box.value = $0 }

        #expect(factory.duckDuckGoCallCount == 1)
        #expect(factory.googleSearchCallCount == 0)
        let result = try #require(box.value)
        let data = try result.get()
        let suggestions = try data.suggestions
        #expect(suggestions == ["ddg-swift"])
    }

    @Test func fetchAutocompleteSuggestionsSkipsDuplicateInFlightQuery() {
        let factory = MockSearchStrategiesFactory()
        let subject = PassthroughSubject<SearchSuggestionsResponse, HttpError>()
        factory.googleSearchStrategyMock.publisherHandler = { _ in
            subject.eraseToAnyPublisher()
        }
        let service = makeService(factory: factory)
        let firstFinished = ResultBox<Bool>()
        let secondFinished = ResultBox<Bool>()
        firstFinished.value = false
        secondFinished.value = false

        service.sendCommand(
            .fetchAutocompleteSuggestions(UUID(), .google, "same"),
            nil
        ) { _ in firstFinished.value = true }

        service.sendCommand(
            .fetchAutocompleteSuggestions(UUID(), .google, "same"),
            nil
        ) { _ in secondFinished.value = true }

        #expect(factory.googleSearchCallCount == 1)
        #expect(factory.googleSearchStrategyMock.publisherCalls == ["same"])
        #expect(firstFinished.value == false)
        #expect(secondFinished.value == false)

        withExtendedLifetime(subject) {}
    }

    @Test func fetchAutocompleteSuggestionsFailure() {
        let factory = MockSearchStrategiesFactory()
        factory.googleSearchStrategyMock.publisherHandler = { _ in
            Fail(error: HttpError.noInternetConnectionWithHost)
                .eraseToAnyPublisher()
        }
        let service = makeService(factory: factory)
        let box = ResultBox<Result<SearchServiceData, SearchServiceError>>()

        service.sendCommand(
            .fetchAutocompleteSuggestions(UUID(), .google, "x"),
            nil
        ) { box.value = $0 }

        guard case .failure(let error) = box.value else {
            Issue.record("Expected failure, got \(String(describing: box.value))")
            return
        }
        guard case .strategyError = error else {
            Issue.record("Expected strategyError, got \(error)")
            return
        }
    }

    // MARK: - DNS

    @Test func resolveDomainNameInURLSuccess() throws {
        let factory = MockSearchStrategiesFactory()
        let original = try #require(URL(string: "https://example.com/path"))
        let resolved = try #require(URL(string: "https://1.2.3.4/path"))
        factory.googleDnsStrategy.publisherHandler = { _ in
            Just(resolved)
                .setFailureType(to: DnsError.self)
                .eraseToAnyPublisher()
        }
        let service = makeService(factory: factory)
        let box = ResultBox<Result<SearchServiceData, SearchServiceError>>()

        service.sendCommand(.resolveDomainNameInURL(UUID(), original), nil) { box.value = $0 }

        #expect(factory.googleDnsCallCount == 1)
        #expect(factory.googleDnsStrategy.publisherCalls == [original])
        let result = try #require(box.value)
        let data = try result.get()
        let resolvedURL = try data.resolvedURL
        #expect(resolvedURL == resolved)
    }

    @Test func resolveDomainNameInURLFailure() throws {
        let factory = MockSearchStrategiesFactory()
        let original = try #require(URL(string: "https://example.com"))
        factory.googleDnsStrategy.publisherHandler = { _ in
            Fail(error: DnsError.noHost).eraseToAnyPublisher()
        }
        let service = makeService(factory: factory)
        let box = ResultBox<Result<SearchServiceData, SearchServiceError>>()

        service.sendCommand(.resolveDomainNameInURL(UUID(), original), nil) { box.value = $0 }

        guard case .failure(let error) = box.value else {
            Issue.record("Expected failure, got \(String(describing: box.value))")
            return
        }
        guard case .strategyError = error else {
            Issue.record("Expected strategyError, got \(error)")
            return
        }
    }

    // MARK: - Search URL

    @Test func fetchSearchURLFallsBackToGoogleSearchEngine() throws {
        let factory = MockSearchStrategiesFactory()
        let service = makeService(factory: factory)
        let suggestion = "cotton browser"
        let expected = try #require(SearchEngine.googleSearchEngine().searchURLForQuery(suggestion))
        let box = ResultBox<Result<SearchServiceData, SearchServiceError>>()

        service.sendCommand(
            .fetchSearchURL(identifier: UUID(), suggestion: suggestion, searchEngineName: .google),
            nil
        ) { box.value = $0 }

        #expect(factory.googleSearchCallCount == 0)
        #expect(factory.googleDnsCallCount == 0)
        let result = try #require(box.value)
        let data = try result.get()
        let searchURL = try data.searchURL
        #expect(searchURL == expected)
    }

    // MARK: - Helpers

    private func makeService(
        factory: MockSearchStrategiesFactory
    ) -> any SearchDataServiceProtocol {
        DataServiceFactory.createSearchService(
            executionQueue: queue,
            responseQueue: queue,
            stratsFactory: factory
        )
    }
}
