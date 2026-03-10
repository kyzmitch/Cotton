//
//  FetchAutocompleteSuggestionsUseCase.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/21/22.
//  Copyright © 2022 Cotton (former Catowser). All rights reserved.
//

import Combine
import CoreBrowser
import CottonSearch
import Foundation
import BaseUseCaseKit
import AutoMockable

// MARK: - Interface

/// Fetch search suggestions and return async task
public protocol FetchAutocompleteSuggestionsUseCase: CoreUseCase, AutoMockable, Sendable {
    
    /// Input
    typealias Input = (source: WebAutoCompletionSource, query: String)
    /// Output
    typealias Output = [String]

    func execute(input: Input) async throws -> Output
}

// MARK: - Implementation


/// Fetch search suggestions and return async task
public final class FetchAutocompleteSuggestionsUseCaseImpl: FetchAutocompleteSuggestionsUseCase {
    
    private let searchDataService: any SearchDataServiceProtocol

    public init(_ searchDataService: any SearchDataServiceProtocol) {
        self.searchDataService = searchDataService
    }

    /// Execute a use case
    public func execute(input: Input) async throws -> Output {
        let suggestions: [String] = try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume(throwing: AppError.zombieSelf)
                return
            }
            let (source, query) = input
            searchDataService.sendCommand(
                .fetchAutocompleteSuggestions(UUID(), source, query),
                nil
            ) { result in
                switch result {
                case .failure(let searchError):
                    continuation.resume(throwing: AppError.searchDataServiceError(searchError))
                case .success(let serviceData):
                    do {
                        continuation.resume(returning: try serviceData.suggestions)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
        return suggestions
    }
}
