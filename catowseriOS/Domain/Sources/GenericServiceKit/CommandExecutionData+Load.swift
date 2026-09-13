//
//  CommandExecutionData+Load.swift
//  GenericServiceKit
//
//  Created by Andrey Ermoshin on 13.09.2026.
//  Copyright © 2026 Cotton (Catowser). All rights reserved.
//

extension CommandExecutionData {
    /// Starts a new load, joins an in-flight one, or returns a cached success.
    ///
    /// - `.inProgress`: await and return that task's result (coalesce).
    /// - `.notStarted` / `.started` / `.finished(.failure)`: start a new load.
    /// - `.finished(.success)`: return the cached value without invoking `operation`.
    ///
    /// On completion the entry is always `.finished` — never left as `.inProgress`
    /// with a completed failed task. Cancellation of a waiter does not cancel the
    /// shared task or record a failure for other callers.
    public mutating func loadOrJoin(
        operation: @escaping @Sendable () async throws -> Output
    ) async throws -> Output {
        let (next, task) = startingOrJoiningLoad(operation: operation)
        self = next
        guard let task else {
            return try cachedSuccessValue()
        }
        return try await awaitAndPromote(task)
    }

    /// Returns the next cache entry and the in-flight task without awaiting.
    ///
    /// A `nil` task means `.finished(.success)` is already cached. Callers that
    /// must publish a sibling `.inProgress` field (for example `tabsCount`)
    /// should assign the returned entry first, then await via `loadOrJoin`.
    public func startingOrJoiningLoad(
        operation: @escaping @Sendable () async throws -> Output
    ) -> (entry: Self, task: Task<Output, E>?) {
        switch self {
        case .inProgress(let task):
            return (self, task)
        case .finished(let output):
            switch output {
            case .success:
                return (self, nil)
            case .failure:
                let task = makeLoadTask(operation)
                return (.inProgress(task), task)
            }
        case .notStarted, .started:
            let task = makeLoadTask(operation)
            return (.inProgress(task), task)
        }
    }
}

extension CommandExecutionData {
    /// Swift only exposes throwing `Task` initializers when `Failure == Error`.
    /// `CommandExecutionData.inProgress` stores `Task<Output, E>`, so this bridges
    /// a throwing unstructured task into that associated type.
    public static func makeInProgressTask(
        _ operation: @escaping @Sendable () async throws -> Output
    ) -> Task<Output, E> {
        let erasing = Task<Output, Error> {
            do {
                return try await operation()
            } catch let error as E {
                throw error
            } catch {
                throw E(zombyInstance: true)
            }
        }
        return unsafeBitCast(erasing, to: Task<Output, E>.self)
    }
}

private extension CommandExecutionData {
    func makeLoadTask(
        _ operation: @escaping @Sendable () async throws -> Output
    ) -> Task<Output, E> {
        Self.makeInProgressTask(operation)
    }

    func cachedSuccessValue() throws -> Output {
        guard
            case let .finished(output) = self,
            case let .success(value) = output
        else {
            throw E(zombyInstance: true)
        }
        return value
    }

    mutating func awaitAndPromote(
        _ task: Task<Output, E>
    ) async throws -> Output {
        do {
            let value = try await task.value
            self = .finished(output: .success(value))
            return value
        } catch is CancellationError where Task.isCancelled {
            throw CancellationError()
        } catch let error as E {
            self = .finished(output: .failure(error))
            throw error
        } catch {
            let wrapped = E(zombyInstance: true)
            self = .finished(output: .failure(wrapped))
            throw wrapped
        }
    }
}
