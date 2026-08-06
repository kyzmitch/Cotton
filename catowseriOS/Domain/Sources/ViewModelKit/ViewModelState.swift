//
//  ViewModelState.swift
//  catowser
//
//  Created by Andrey Ermoshin on 17.12.2024.
//  Copyright © 2024 Cotton (Catowser). All rights reserved.
//

/// View model state marker interface
///
/// Can be value type (struct or enum) to be thread-safe out of the box.
/// But it is not required, you can use classes and inheritance to
/// implement canonical state design pattern as well.
///
/// Transition logic lives in `StateTransitioning` / `ViewModelStateMachine`,
/// not on this protocol.
public protocol ViewModelState: Sendable, Equatable {
    /// Action type
    associatedtype Action: ViewModelAction
    /// Context of the state to be able to get any additional data
    /// required for action handling or state conversion.
    associatedtype Context: StateContext
    /// Base state type, needed for class/ref states to be able to use base class
    /// in initial instance and transition functions.
    associatedtype BaseState: ViewModelState where BaseState.Action == Action, BaseState.Context == Context

    /// Create an initial state which is needed for View Model init
    ///
    /// e.g. it could be loading state at the beginning
    static func createInitial() -> BaseState
}
