//
//  SearchSuggestionsStateTransitioningTests.swift
//  CottonViewModelsTests
//

import Foundation
import Testing
@testable import CottonViewModels

@MainActor
private final class FakeSearchSuggestionsStateContext: SearchSuggestionsStateContext {
    var domainsByQuery: [String: KnownDomains] = [:]
    var suggestionsByQuery: [String: QuerySuggestions] = [:]
    var autocompleteError: Error?

    func knownDomains(matching query: String) async -> KnownDomains {
        domainsByQuery[query] ?? []
    }

    func autocompleteSuggestions(for query: String) async throws -> QuerySuggestions {
        if let autocompleteError {
            throw autocompleteError
        }
        return suggestionsByQuery[query] ?? []
    }
}

private struct SoftFailError: Error {}

struct SearchSuggestionsStateTransitioningTests {
    @MainActor
    @Test func loadKnownDomainsReturnsKnownDomainsLoaded() async throws {
        let context = FakeSearchSuggestionsStateContext()
        context.domainsByQuery["g"] = ["google.com", "gmail.com"]
        let strategy = SearchSuggestionsStateTransitioning<FakeSearchSuggestionsStateContext>()

        let next = try await strategy.transition(
            from: .waitingForQuery,
            on: .loadKnownDomains("g"),
            with: context
        )

        #expect(next == .knownDomainsLoaded(["google.com", "gmail.com"]))
    }

    @MainActor
    @Test func loadSuggestionsFromKnownDomainsReturnsEverythingLoaded() async throws {
        let context = FakeSearchSuggestionsStateContext()
        context.suggestionsByQuery["g"] = ["google", "gmail"]
        let strategy = SearchSuggestionsStateTransitioning<FakeSearchSuggestionsStateContext>()

        let next = try await strategy.transition(
            from: .knownDomainsLoaded(["google.com"]),
            on: .loadSuggestions("g"),
            with: context
        )

        #expect(next == .everythingLoaded(["google.com"], ["google", "gmail"]))
    }

    @MainActor
    @Test func loadSuggestionsSoftFailsToEmptySuggestions() async throws {
        let context = FakeSearchSuggestionsStateContext()
        context.autocompleteError = SoftFailError()
        let strategy = SearchSuggestionsStateTransitioning<FakeSearchSuggestionsStateContext>()

        let next = try await strategy.transition(
            from: .knownDomainsLoaded(["google.com"]),
            on: .loadSuggestions("g"),
            with: context
        )

        #expect(next == .everythingLoaded(["google.com"], []))
    }

    @MainActor
    @Test func loadSuggestionsFromWaitingForQueryThrows() async {
        let context = FakeSearchSuggestionsStateContext()
        let strategy = SearchSuggestionsStateTransitioning<FakeSearchSuggestionsStateContext>()
        let initial: SearchSuggestionsViewState<FakeSearchSuggestionsStateContext> = .waitingForQuery

        await #expect(throws: SearchSuggestionsViewState<FakeSearchSuggestionsStateContext>.Error.self) {
            _ = try await strategy.transition(
                from: initial,
                on: .loadSuggestions("g"),
                with: context
            )
        }
    }

    @MainActor
    @Test func missingContextThrows() async {
        let strategy = SearchSuggestionsStateTransitioning<FakeSearchSuggestionsStateContext>()
        let initial: SearchSuggestionsViewState<FakeSearchSuggestionsStateContext> = .waitingForQuery

        await #expect(throws: SearchSuggestionsViewState<FakeSearchSuggestionsStateContext>.Error.self) {
            _ = try await strategy.transition(
                from: initial,
                on: .loadKnownDomains("g"),
                with: nil
            )
        }
    }
}
