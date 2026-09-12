//
//  FakeSelectTabUseCase.swift
//  CottonUseCasesTests
//

import CoreBrowser
import CottonUseCases

/// Tracks `SelectTabUseCase` invocations; optionally delegates to a real implementation.
final class FakeSelectTabUseCase: SelectTabUseCase, @unchecked Sendable {
    private let real: (any SelectTabUseCase)?
    private(set) var executeCalls: [CoreBrowser.Tab] = []
    var executeHandler: (@Sendable (CoreBrowser.Tab) async throws -> Void)?

    init(real: (any SelectTabUseCase)? = nil) {
        self.real = real
    }

    func execute(input tab: CoreBrowser.Tab) async throws {
        executeCalls.append(tab)
        if let executeHandler {
            try await executeHandler(tab)
        } else if let real {
            try await real.execute(input: tab)
        }
    }
}
