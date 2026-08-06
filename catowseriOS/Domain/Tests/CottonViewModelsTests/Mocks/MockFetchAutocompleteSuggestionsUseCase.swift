//
//  MockFetchAutocompleteSuggestionsUseCase.swift
//  CottonViewModelsTests
//

import CoreBrowser
import CottonUseCases

/// Hand-written mock for the simple autocomplete use case used by search suggestions VM tests.
final class MockFetchAutocompleteSuggestionsUseCase: FetchAutocompleteSuggestionsUseCase, @unchecked Sendable {
    var executeHandler: (@Sendable (Input) async throws -> Output)?
    private(set) var executeCalls: [Input] = []

    func execute(input: Input) async throws -> Output {
        executeCalls.append(input)
        guard let executeHandler else {
            preconditionFailure("MockFetchAutocompleteSuggestionsUseCase.executeHandler was not set")
        }
        return try await executeHandler(input)
    }
}
