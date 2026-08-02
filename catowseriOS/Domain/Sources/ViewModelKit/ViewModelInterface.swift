//
//  ViewModelInterface.swift
//  catowser
//
//  Created by Andrey Ermoshin on 17.12.2024.
//  Copyright © 2024 Cotton (Catowser). All rights reserved.
//

import Combine

/// Base view model interface.
///
/// Always has to be a reference type (AnyObject)
@MainActor public protocol ViewModelInterface: AnyObject, Sendable {
    /// Type of the associated state
    associatedtype State: ViewModelState where State == State.BaseState
    /// Type of an action
    associatedtype Action: ViewModelAction where Action == State.Action
    /// State context to not expose the view model type.
    associatedtype Context: StateContext where State.Context == Context
    /// Completion callback type
    typealias CompletionCallback = (Result<Void, Error>) -> Void

    /// UI state of view model
    var state: State { get set }
    /// Combine publisher for the UI state
    var statePublisher: Published<State>.Publisher { get }
    /// State context which could help to convert the state on incoming action.
    /// Usually it should be a wrapper around view model implementation.
    var context: Context? { get }

    /// Fire-and-forget apply of one action (no caller `Task` needed).
    /// Errors are ignored unless using `onComplete`.
    func sendAction(_ action: Action)
    /// Awaitable apply of one action — use when the caller must wait or chain in order.
    /// - Throws if the action is invalid for the current state or due to other errors.
    func sendAction(_ action: Action) async throws
    /// Apply one action and deliver the outcome to `onComplete`.
    func sendAction(
        _ action: Action,
        onComplete: CompletionCallback?
    )

    /// Fire-and-forget apply of several actions **in order** (no caller `Task` needed).
    func sendActions(_ actions: [Action])
    /// Awaitable ordered apply — preferred when the caller is already `async`.
    func sendActions(_ actions: [Action]) async throws
    /// Ordered apply with a single completion for the whole sequence (stops on first error).
    func sendActions(
        _ actions: [Action],
        onComplete: CompletionCallback?
    )
}

extension ViewModelInterface {
    public func sendAction(_ action: Action) {
        sendAction(action, onComplete: nil)
    }

    /// Default completion-based API delegates to the async `sendAction`.
    ///
    /// Conformers such as `BaseViewModel` must implement the async path via
    /// `ViewModelStateMachine` (not via state-level transition APIs).
    public func sendAction(
        _ action: Action,
        onComplete: CompletionCallback?
    ) {
        Task {
            do {
                try await sendAction(action)
                onComplete?(.success(()))
            } catch {
                onComplete?(.failure(error))
            }
        }
    }

    public func sendActions(_ actions: [Action]) {
        sendActions(actions, onComplete: nil)
    }

    public func sendActions(_ actions: [Action]) async throws {
        for action in actions {
            try await sendAction(action)
        }
    }

    public func sendActions(
        _ actions: [Action],
        onComplete: CompletionCallback?
    ) {
        Task {
            do {
                try await sendActions(actions)
                onComplete?(.success(()))
            } catch {
                onComplete?(.failure(error))
            }
        }
    }
}
