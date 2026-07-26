//
//  MockResolveDNSUseCase.swift
//  CottonViewModelsTests
//

import Foundation
import CottonUseCases

/// Hand-written mock for ResolveDNSUseCase (Mockable cannot expand inherited CoreUseCase requirements).
final class MockResolveDNSUseCase: ResolveDNSUseCase, @unchecked Sendable {
    var executeHandler: (@Sendable (URL) async throws -> URL)?
    private(set) var executeCalls: [URL] = []

    func execute(input: URL) async throws -> URL {
        executeCalls.append(input)
        guard let executeHandler else {
            preconditionFailure("MockResolveDNSUseCase.executeHandler was not set")
        }
        return try await executeHandler(input)
    }
}
