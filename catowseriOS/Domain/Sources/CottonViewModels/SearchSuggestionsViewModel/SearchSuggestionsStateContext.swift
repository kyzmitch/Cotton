//
//  SearchSuggestionsStateContext.swift
//  CottonViewModels
//
//  Copyright © 2026 Cotton (Catowser). All rights reserved.
//

import ViewModelKit

/// Side-effect surface for SearchSuggestions transitions without exposing the impl.
@MainActor public protocol SearchSuggestionsStateContext: StateContext {
    /// Known domains whose URLs contain `query`.
    func knownDomains(matching query: String) async -> KnownDomains
    /// Remote autocomplete suggestions for `query` (throws on network/service failure).
    func autocompleteSuggestions(for query: String) async throws -> QuerySuggestions
}

/// Proxy that hides the view model implementation from the transition strategy.
public final class SearchSuggestionsStateContextProxy: SearchSuggestionsStateContext {
    private let subject: any SearchSuggestionsStateContext

    init(subject: any SearchSuggestionsStateContext) {
        self.subject = subject
    }

    public func knownDomains(matching query: String) async -> KnownDomains {
        await subject.knownDomains(matching: query)
    }

    public func autocompleteSuggestions(for query: String) async throws -> QuerySuggestions {
        try await subject.autocompleteSuggestions(for: query)
    }
}
