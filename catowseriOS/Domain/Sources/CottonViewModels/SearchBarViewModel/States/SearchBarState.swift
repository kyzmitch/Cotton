//
//  SearchBarState.swift
//  catowser
//
//  Created by Andrey Ermoshin on 30.12.2024.
//  Copyright © 2024 Cotton (Catowser). All rights reserved.
//

import ViewModelKit

/// Base search bar state
public class SearchBarState<C: SearchBarStateContext>: ViewModelState, @unchecked Sendable {
    public typealias Context = C
    public typealias Action = SearchBarAction
    public typealias BaseState = SearchBarState<C>

    /// This is a text for the overlay label above the search bar
    public var overlayContent: String?
    /// This is a text for the search bar itself
    public var searchBarContent: String?
    /// Search request text
    public var query: String?

    /// GoF State handler for this mode (not part of `ViewModelState`).
    @MainActor open var modeHandler: any SearchBarModeHandler<C> {
        SearchBarInvalidModeHandler<C>()
    }

    init() { }

    /// Initial state without search bar or overlay content
    public static func createInitial() -> BaseState {
        return SearchBarInViewMode<C>()
    }

    /// Text of overlay label
    public var overlay: String {
        overlayContent ?? ""
    }

    /// Text for search bar
    public var content: String {
        searchBarContent ?? ""
    }

    /// Determines if cancel button needs to be shown
    open var showCancelButton: Bool {
        false
    }

    public static func == (lhs: SearchBarState<C>, rhs: SearchBarState<C>) -> Bool {
        guard type(of: lhs) == type(of: rhs) else {
            return false
        }
        return lhs.showCancelButton == rhs.showCancelButton &&
            lhs.overlayContent == rhs.overlayContent &&
            lhs.searchBarContent == rhs.searchBarContent &&
            lhs.query == rhs.query &&
            lhs.showCancelButton == rhs.showCancelButton
    }
}

/// Transition strategy that dispatches to the current state's mode handler.
public struct SearchBarStateTransitioning<C: SearchBarStateContext>: StateTransitioning {
    public typealias State = SearchBarState<C>

    public init() {}

    @MainActor public func transition(
        from state: State,
        on action: State.Action,
        with context: State.Context?
    ) async throws -> State {
        try await state.modeHandler.transition(state, on: action, with: context)
    }
}
