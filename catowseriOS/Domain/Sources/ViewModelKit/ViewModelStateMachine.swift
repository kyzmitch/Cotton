//
//  ViewModelStateMachine.swift
//  ViewModelKit
//
//  Copyright © 2026 Cotton (Catowser). All rights reserved.
//

/// Generic async state machine for MVVM (GoF Context + Strategy).
///
/// Owns the current `ViewModelState` and applies actions through a
/// pluggable `StateTransitioning` strategy. On failure, the previous
/// state is preserved.
@MainActor
public final class ViewModelStateMachine<State: ViewModelState>: Sendable where State == State.BaseState {
    /// Current UI state
    public private(set) var state: State
    private var transitioning: any StateTransitioning<State>

    /// Creates a machine with an initial state and transition strategy.
    public init(
        initialState: State = .createInitial(),
        transitioning: any StateTransitioning<State>
    ) {
        self.state = initialState
        self.transitioning = transitioning
    }

    /// Applies `action` using the strategy. Leaves `state` unchanged if the strategy throws.
    public func send(
        _ action: State.Action,
        with context: State.Context?
    ) async throws {
        let nextState = try await transitioning.transition(
            from: state,
            on: action,
            with: context
        )
        state = nextState
    }

    /// Replaces current state without running a transition (e.g. sync after external mutation).
    public func replaceState(_ state: State) {
        self.state = state
    }

    /// Package/test hook to substitute the transition strategy.
    func setTransitioningForTests(_ transitioning: any StateTransitioning<State>) {
        self.transitioning = transitioning
    }
}
