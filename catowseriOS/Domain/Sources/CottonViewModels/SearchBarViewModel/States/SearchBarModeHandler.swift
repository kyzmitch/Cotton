//
//  SearchBarModeHandler.swift
//  CottonViewModels
//
//  Copyright © 2026 Cotton (Catowser). All rights reserved.
//

/// GoF State pattern: per-mode transition handler for search bar states.
@MainActor
public protocol SearchBarModeHandler<Context>: Sendable {
    associatedtype Context: SearchBarStateContext

    func transition(
        _ state: SearchBarState<Context>,
        on action: SearchBarAction,
        with context: Context?
    ) async throws -> SearchBarState<Context>
}

/// Fallback handler for the abstract base search-bar state.
struct SearchBarInvalidModeHandler<Context: SearchBarStateContext>: SearchBarModeHandler {
    func transition(
        _ state: SearchBarState<Context>,
        on action: SearchBarAction,
        with context: Context?
    ) async throws -> SearchBarState<Context> {
        throw SearchBarError.invalidDummyState
    }
}

/// Handler for view mode (canonical State object for `SearchBarInViewMode`).
struct SearchBarInViewModeHandler<Context: SearchBarStateContext>: SearchBarModeHandler {
    func transition(
        _ state: SearchBarState<Context>,
        on action: SearchBarAction,
        with context: Context?
    ) async throws -> SearchBarState<Context> {
        switch action {
        case .startSearch(let query):
            return SearchBarInSearchMode<Context>(
                query,
                state.overlayContent,
                state.searchBarContent
            )
        case .cancelSearch:
            throw SearchBarError.cannotCancelSearchWhenInViewMode
        case let .updateView(overlayLabel, searchBarContent):
            state.overlayContent = overlayLabel
            state.searchBarContent = searchBarContent
            return state
        case .clearView:
            return SearchBarInViewMode<Context>()
        case .selectSuggestion:
            throw SearchBarError.cannotSeeSuggestionsInViewMode
        }
    }
}

/// Handler for search mode (canonical State object for `SearchBarInSearchMode`).
struct SearchBarInSearchModeHandler<Context: SearchBarStateContext>: SearchBarModeHandler {
    func transition(
        _ state: SearchBarState<Context>,
        on action: SearchBarAction,
        with context: Context?
    ) async throws -> SearchBarState<Context> {
        switch action {
        case .startSearch:
            throw SearchBarError.alreadyInSearchMode
        case .cancelSearch:
            return SearchBarInViewMode<Context>(
                state.overlayContent,
                state.searchBarContent
            )
        case let .updateView(overlayLabel, searchBarContent):
            state.overlayContent = overlayLabel
            state.searchBarContent = searchBarContent
            return state
        case .clearView:
            return SearchBarInViewMode<Context>()
        case .selectSuggestion(let suggestion):
            try await context?.searchSuggestionDidSelect(suggestion)
            return SearchBarInViewMode<Context>()
        }
    }
}
