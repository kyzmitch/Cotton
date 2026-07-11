//
//  CommandExecutionData.swift
//  GenericServiceKit
//
//  Created by Andrey Ermoshin on 03.12.2024.
//  Copyright © 2024 Cotton (Catowser). All rights reserved.
//

/// A typealias for sendable and equatable protocols together
public typealias SendableEquatable = Sendable // & Equatable

/// Command execution state is a common data structure
/// which combines all possible data related to specific command.
/// Each command optionally could have an input data
/// and each command for sure must have an output or an error
/// at the end of execution.
///
/// Should be used only inside GenericServiceData implementations.
/// The most close system's type is `Result`, but it doesn't allow to store the input data.
public enum CommandExecutionData<
    Input: SendableEquatable,
    Output: SendableEquatable,
    E: DataServiceKitError
>: SendableEquatable {
    /// No one started the command
    case notStarted
    /// Command is going to be started
    case started(input: Input?)
    /// Command is in progress if it is async
    case inProgress(Task<Output, E>)
    /// Command has finished
    case finished(output: Result<Output, E>)
}
