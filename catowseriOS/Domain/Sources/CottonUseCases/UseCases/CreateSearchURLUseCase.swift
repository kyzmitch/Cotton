//
//  CreateSearchURLUseCase.swift
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

/// Create search URL using selected search engine and return async task
public protocol CreateSearchURLUseCase: CoreUseCase, AutoMockable, Sendable {
    
    /// Input
    typealias Input = (source: WebAutoCompletionSource, suggestion: String)
    /// Output which is URL
    typealias Output = URL

    func execute(input: Input) async throws -> Output
}

// MARK: - Implementation

/// Create search URL using selected search engine and return async task
public final class CreateSearchURLUseCaseImpl: CreateSearchURLUseCase {
    private let searchDataService: any SearchDataServiceProtocol
    
    /// Init
    public init(_ searchDataService: any SearchDataServiceProtocol) {
        self.searchDataService = searchDataService
    }
    
    /// Executes the use case
    public func execute(input: Input) async throws -> Output {
        let searchURL: URL = try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume(throwing: AppError.zombieSelf)
                return
            }
            let (source, suggestion) = input
            searchDataService.sendCommand(
                .fetchSearchURL(
                    identifier: UUID(),
                    suggestion: suggestion,
                    searchEngineName: source
                ),
                nil
            ) { result in
                switch result {
                case .failure(let searchError):
                    continuation.resume(throwing: AppError.searchDataServiceError(searchError))
                case .success(let serviceData):
                    do {
                        continuation.resume(returning: try serviceData.searchURL)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
        return searchURL
    }
}
