//
//  SearchSuggestionsStateTransitioning.swift
//  CottonViewModels
//
//  Copyright © 2026 Cotton (Catowser). All rights reserved.
//

import ViewModelKit

/// Async transition strategy for SearchSuggestions domain state.
///
/// Progressive UI requires two machine transitions per query:
/// `.loadKnownDomains` → `.knownDomainsLoaded`, then `.loadSuggestions` → `.everythingLoaded`.
public struct SearchSuggestionsStateTransitioning<C: SearchSuggestionsStateContext>: StateTransitioning {
    public typealias State = SearchSuggestionsViewState<C>

    public init() {}

    @MainActor public func transition(
        from state: State,
        on action: State.Action,
        with context: State.Context?
    ) async throws -> State {
        guard let context else {
            throw State.Error.missingContext
        }
        try Task.checkCancellation()

        switch action {
        case .loadKnownDomains(let query):
            let domains = await context.knownDomains(matching: query)
            try Task.checkCancellation()
            return .knownDomainsLoaded(domains)

        case .loadSuggestions(let query):
            let domains: KnownDomains
            switch state {
            case .knownDomainsLoaded(let known):
                domains = known
            case .everythingLoaded(let known, _):
                domains = known
            case .waitingForQuery:
                throw State.Error.unexpectedStateForAction(state, action)
            }
            do {
                let suggestions = try await context.autocompleteSuggestions(for: query)
                try Task.checkCancellation()
                return .everythingLoaded(domains, suggestions)
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                // Soft-fail: show known domains with empty remote suggestions.
                return .everythingLoaded(domains, [])
            }
        }
    }
}
