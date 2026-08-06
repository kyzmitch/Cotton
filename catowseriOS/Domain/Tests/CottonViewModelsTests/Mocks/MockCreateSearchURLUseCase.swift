//
//  MockCreateSearchURLUseCase.swift
//  CottonViewModelsTests
//

import CoreBrowser
import Foundation
import CottonUseCases

/// Hand-written mock for CreateSearchURLUseCase (Mockable cannot expand inherited CoreUseCase requirements).
final class MockCreateSearchURLUseCase: CreateSearchURLUseCase, @unchecked Sendable {
    var executeHandler: (@Sendable (Input) async throws -> Output)?
    private(set) var executeCalls: [Input] = []

    func execute(input: Input) async throws -> Output {
        executeCalls.append(input)
        guard let executeHandler else {
            preconditionFailure("MockCreateSearchURLUseCase.executeHandler was not set")
        }
        return try await executeHandler(input)
    }
}
