//
//  BaseViewModel.swift
//  catowser
//
//  Created by Andrey Ermoshin on 17.12.2024.
//  Copyright © 2024 Cotton (Catowser). All rights reserved.
//

import Combine

/// Base view model type.
///
/// It implements default code for base inerface and allows to use the actual types
/// for the state, action & state context.
///
/// It can be used for SwiftUI because it confirms to `ObservableObject` as well.
///
/// Transitions run through a private `ViewModelStateMachine`; the machine is not
/// part of the public API.
@MainActor
open class BaseViewModel<
    S: ViewModelState,
    A: ViewModelAction,
    C: StateContext
>: ViewModelInterface, ObservableObject where S.Action == A, S.Context == C, S.BaseState == S {
    public typealias Action = A
    public typealias State = S
    public typealias Context = C

    /// UI state of view model
    @Published public var state: State
    /// Combine publisher for the UI state
    public var statePublisher: Published<State>.Publisher { $state }
    /// State context computed property, it is nil for the base view model
    /// because the actual context type is not determined yet.
    open var context: Context? { nil }

    private let stateMachine: ViewModelStateMachine<S>

    /// Creates a base view model with a transition strategy and initial UI state.
    public init(transitioning: any StateTransitioning<S>) {
        let initialState = S.createInitial()
        let machine = ViewModelStateMachine(
            initialState: initialState,
            transitioning: transitioning
        )
        self.stateMachine = machine
        self.state = initialState
    }

    /// Package/test hook: construct with a fully configured machine.
    init(stateMachine: ViewModelStateMachine<S>) {
        self.stateMachine = stateMachine
        self.state = stateMachine.state
    }

    /// Apply an action to the view model state to get a new valid state.
    ///
    /// Prefer:
    /// - `sendAction(_:)` / `sendActions(_:)` for sync UIKit call sites (fire-and-forget)
    /// - `sendAction(_:) async` / `sendActions(_:) async` when order or errors must be awaited
    /// - Parameter action: an action to apply to the state
    /// - Throws if the action is invalid for the current state or due to other errors
    open func sendAction(
        _ action: Action
    ) async throws {
        // Pick up any direct `state` mutations (e.g. side-effect resets) before transitioning.
        stateMachine.replaceState(state)
        try await stateMachine.send(action, with: context)
        state = stateMachine.state
    }

    /// Package/test hook to substitute the transition strategy.
    func setTransitioningForTests(_ transitioning: any StateTransitioning<S>) {
        stateMachine.setTransitioningForTests(transitioning)
    }
}
