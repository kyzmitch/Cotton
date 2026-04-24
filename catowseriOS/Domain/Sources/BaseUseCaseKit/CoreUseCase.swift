//
//  CoreUseCase.swift
//  GenericServiceKit
//
//  Created by Andrey Ermoshin on 03.09.2025.
//  Copyright © 2025 Cotton (Catowser). All rights reserved.
//

// MARK: - Interface

/// A common interface for the canonical use cases.
public protocol CoreUseCase: AnyObject, Sendable {
    /// Input type can be determined only at the place of use, not at init (can't register a use case in DI with a known input)
    /// Input must be sendable to allow to pass it to the task.
    associatedtype Input: Sendable
    /// Output type for specific Domain of business logic
    associatedtype Output: Sendable
    
    /// Execute a use case with some input
    ///
    /// - Parameter input: Any input, could be Void
    /// - Returns An output value or throws an error
    func execute(input: Input) async throws -> Output
}

// MARK: - Extension

extension CoreUseCase {
    /// Creates an async task which may be cancelled and executed later on.
    ///
    /// - Parameters:
    ///  - input  Any input, could be Void
    ///  - priority An optional task priority
    /// - Returns An async task
    public func makeTask(
        input: Input,
        priority: TaskPriority?
    ) -> Task<Output, Error> {
        Task(priority: priority) {
            try await execute(input: input)
        }
    }
}

// MARK: - Empty extension

extension CoreUseCase where Input == Void {
    /// Execute a use case without any input
    ///
    /// - Returns An output value or throws an error
    public func execute() async throws -> Output {
        try await execute(input: ())
    }

    /// Creates an async task which may be cancelled and executed later on.
    ///
    /// - Parameters:
    ///  - priority An optional task priority
    /// - Returns An async task
    public func makeTask(priority: TaskPriority?) -> Task<Output, Error> {
        makeTask(input: (), priority: priority)
    }
}

// MARK: - Empty output

extension CoreUseCase where Input == Void, Output == Void {
    /// Execute a use case without any input and output
    ///
    /// - Returns Nothing or throws an error
    public func execute() async throws {
        try await execute(input: ())
    }

    /// Creates an async task which may be cancelled and executed later on.
    ///
    /// - Parameters:
    ///  - priority An optional task priority
    /// - Returns An async task
    public func makeTask(priority: TaskPriority?) -> Task<Void, Error> {
        makeTask(input: (), priority: priority)
    }
}
