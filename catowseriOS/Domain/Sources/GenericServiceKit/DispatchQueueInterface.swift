//
//  DispatchQueueInterface.swift
//  GenericServiceKit
//
//  Created by Andrey Ermoshin on 25.11.2024.
//  Copyright © 2024 Cotton (Catowser). All rights reserved.
//

import Dispatch

/// Dispatch queue abstract interface
public protocol DispatchQueueInterface: Sendable {
    /// Perform an async code
    /// - work: A sendable and escaping closure to execute in async way on this Dispatch queue
    @preconcurrency func performAsync(
        execute work: @escaping @Sendable @convention(block) () -> Void
    )
}

extension DispatchQueue: DispatchQueueInterface {
    /// Perform an async code (without preconcurrency)
    ///
    /// - work: A sendable and escaping closure to execute in async way on this Dispatch queue
    public func performAsync(
        execute work: @escaping @Sendable @convention(block) () -> Void
    ) {
        self.async(execute: work)
    }
}
