//
//  MockSelectedTabUseCase.swift
//  CottonViewModelsTests
//

import Foundation
import CottonUseCases

/// Hand-written mock for SelectedTabUseCase (Mockable cannot expand inherited CoreUseCase requirements).
final class MockSelectedTabUseCase: SelectedTabUseCase, @unchecked Sendable {
    var executeHandler: (@Sendable (Data?) async throws -> Void)?
    private(set) var executeCalls: [Data?] = []

    func execute(input: Data?) async throws {
        executeCalls.append(input)
        if let executeHandler {
            try await executeHandler(input)
        }
    }
}
