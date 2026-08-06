//
//  StateTransitioning.swift
//  ViewModelKit
//
//  Copyright © 2026 Cotton (Catowser). All rights reserved.
//

/// Strategy that computes the next view-model state for an action.
///
/// Used by `ViewModelStateMachine` (GoF Strategy). State types themselves
/// do not declare transitions.
@MainActor
public protocol StateTransitioning<State>: Sendable {
    /// State type this strategy transitions.
    associatedtype State: ViewModelState where State == State.BaseState

    /// Converts `state` to the next valid state for `action`.
    ///
    /// - Parameters:
    ///   - state: Current UI state
    ///   - action: Action describing the intended transition
    ///   - context: Optional state context for side effects / data loading
    /// - Returns: Next state (may be the same instance/value)
    func transition(
        from state: State,
        on action: State.Action,
        with context: State.Context?
    ) async throws -> State
}

/// Closure-based `StateTransitioning` adapter for relocating existing transition bodies.
public struct ClosureStateTransitioning<State: ViewModelState>: StateTransitioning, @unchecked Sendable
    where State == State.BaseState {
    public typealias Transition = @MainActor (State, State.Action, State.Context?) async throws -> State

    private let body: Transition

    public init(_ body: @escaping Transition) {
        self.body = body
    }

    public func transition(
        from state: State,
        on action: State.Action,
        with context: State.Context?
    ) async throws -> State {
        try await body(state, action, context)
    }
}
