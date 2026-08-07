//
//  TopSitesStateTransitioning.swift
//  CottonViewModels
//
//  Copyright © 2026 Cotton (Catowser). All rights reserved.
//

import ViewModelKit

/// Transition strategy for `TopSitesViewState`.
public struct TopSitesStateTransitioning<C: TopSitesStateContext>: StateTransitioning {
    public typealias State = TopSitesViewState<C>

    public init() {}

    @MainActor public func transition(
        from state: State,
        on action: State.Action,
        with context: State.Context?
    ) async throws -> State {
        switch action {
        case .replaceSelected(let content):
            await context?.replaceSelectedTab(with: content)
        }
        // Sites are seed-only; replace is a side effect that does not mutate UI state.
        return state
    }
}
