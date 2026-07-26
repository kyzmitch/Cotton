//
//  MockReplaceSelectedTabUseCase.swift
//  CottonViewModelsTests
//

import CoreBrowser
import CottonUseCases

/// Hand-written mock for ReplaceSelectedTabUseCase (Mockable cannot expand inherited CoreUseCase requirements).
final class MockReplaceSelectedTabUseCase: ReplaceSelectedTabUseCase, @unchecked Sendable {
    var executeHandler: (@Sendable (CoreBrowser.Tab.ContentType) async throws -> Void)?
    private(set) var executeCalls: [CoreBrowser.Tab.ContentType] = []

    func execute(input: CoreBrowser.Tab.ContentType) async throws {
        executeCalls.append(input)
        if let executeHandler {
            try await executeHandler(input)
        }
    }
}
