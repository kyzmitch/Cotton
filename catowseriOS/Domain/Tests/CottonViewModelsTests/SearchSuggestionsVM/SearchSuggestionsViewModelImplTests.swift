//
//  SearchSuggestionsViewModelImplTests.swift
//  CottonViewModelsTests
//

import Combine
import CoreBrowser
import CottonRestKit
import FeatureFlagsKit
import Foundation
import Testing
@testable import CottonViewModels

actor FakeKnownDomainsSource: KnownDomainsSource {
    private var domainsByQuery: [String: [String]] = [:]

    func setDomains(_ domains: [String], for query: String) {
        domainsByQuery[query] = domains
    }

    func domainNames(whereURLContains filter: String) async -> [String] {
        domainsByQuery[filter] ?? []
    }
}

@MainActor
private final class FakeSearchViewContext: SearchViewContext {
    let knownDomainsStorage: KnownDomainsSource
    var webAutocompletionSource: WebAutoCompletionSource = .google

    init(knownDomainsStorage: KnownDomainsSource) {
        self.knownDomainsStorage = knownDomainsStorage
    }

    var appAsyncApiTypeValue: AsyncApiType {
        get async { .asyncAwait }
    }

    var webAutocompletionSourceValue: WebAutoCompletionSource {
        get async { webAutocompletionSource }
    }
}

@MainActor
private struct SearchSuggestionsVMTestFixture {
    let knownDomains = FakeKnownDomainsSource()
    let autocompleteUseCase = MockFetchAutocompleteSuggestionsUseCase()
    lazy var searchContext = FakeSearchViewContext(knownDomainsStorage: knownDomains)

    mutating func makeViewModel() -> SearchSuggestionsViewModelImpl {
        SearchSuggestionsViewModelImpl(autocompleteUseCase, searchContext)
    }
}

struct SearchSuggestionsViewModelImplTests {
    @MainActor
    @Test func initialStateIsWaitingForQuery() {
        var fixture = SearchSuggestionsVMTestFixture()
        let vm = fixture.makeViewModel()
        #expect(vm.state == .waitingForQuery)
        #expect(vm.context != nil)
    }

    @MainActor
    @Test func fetchSuggestionsPublishesProgressiveThenFinalState() async throws {
        var fixture = SearchSuggestionsVMTestFixture()
        await fixture.knownDomains.setDomains(["google.com", "gmail.com"], for: "g")
        fixture.autocompleteUseCase.executeHandler = { input in
            #expect(input.source == .google)
            #expect(input.query == "g")
            return ["google", "gmail"]
        }
        let vm = fixture.makeViewModel()

        var published: [SearchSuggestionsState] = []
        let cancellable = vm.statePublisher.sink { published.append($0) }
        defer { cancellable.cancel() }

        await vm.fetchSuggestions("g")

        #expect(published.contains(.knownDomainsLoaded(["google.com", "gmail.com"])))
        #expect(vm.state == .everythingLoaded(["google.com", "gmail.com"], ["google", "gmail"]))
        if let knownIndex = published.firstIndex(of: .knownDomainsLoaded(["google.com", "gmail.com"])),
           let finalIndex = published.firstIndex(of: .everythingLoaded(["google.com", "gmail.com"], ["google", "gmail"])) {
            #expect(knownIndex < finalIndex)
        } else {
            Issue.record("Expected progressive knownDomains then everythingLoaded publishes")
        }
    }

    @MainActor
    @Test func fetchSuggestionsSoftFailsAutocomplete() async throws {
        var fixture = SearchSuggestionsVMTestFixture()
        await fixture.knownDomains.setDomains(["google.com"], for: "g")
        fixture.autocompleteUseCase.executeHandler = { _ in
            throw HttpError.httpFailure(error: EndpointHttpError())
        }
        let vm = fixture.makeViewModel()

        await vm.fetchSuggestions("g")

        #expect(vm.state == .everythingLoaded(["google.com"], []))
    }

    @MainActor
    @Test func loadSuggestionsWithoutKnownDomainsThrowsAndPreservesState() async {
        var fixture = SearchSuggestionsVMTestFixture()
        let vm = fixture.makeViewModel()
        #expect(vm.state == .waitingForQuery)

        await #expect(throws: SearchSuggestionsState.Error.self) {
            try await vm.sendAction(.loadSuggestions("g"))
        }
        #expect(vm.state == .waitingForQuery)
    }
}
