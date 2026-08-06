//
//  ImmediateDispatchQueue.swift
//  CottonSearchTests
//

import GenericServiceKit

/// Runs work inline so data-service command handling stays synchronous in unit tests.
struct ImmediateDispatchQueue: DispatchQueueInterface {
    func performAsync(
        execute work: @escaping @Sendable @convention(block) () -> Void
    ) {
        work()
    }
}
