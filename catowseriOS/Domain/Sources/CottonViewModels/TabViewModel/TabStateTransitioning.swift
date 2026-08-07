//
//  TabStateTransitioning.swift
//  CottonViewModels
//
//  Copyright © 2026 Cotton (Catowser). All rights reserved.
//

import ViewModelKit

/// Async transition strategy for Tab domain state.
public struct TabStateTransitioning<C: TabStateContext>: StateTransitioning {
    public typealias State = TabViewState<C>

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
        case .load:
            let isSelected = try await context.isTabSelected()
            try Task.checkCancellation()
            let favicon = await context.loadFavicon()
            try Task.checkCancellation()
            let title = context.tabTitle
            return isSelected
                ? .selected(title, favicon)
                : .deSelected(title, favicon)

        case .applySelection(let isSelected):
            return isSelected ? state.selected() : state.deSelected()

        case .applyReplace(let title, let favicon):
            return state.withNew(title, favicon)

        case .close:
            await context.closeTab()
            return state

        case .activate:
            await context.activateTab()
            return state
        }
    }
}
