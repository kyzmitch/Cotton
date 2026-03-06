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

public final class FetchAutocompleteSuggestionsUseCase: CoreUseCase {
    public typealias Input = (source: WebAutoCompletionSource, query: String)
    public typealias Output = [String]
    
    private let searchDataService: any SearchDataServiceProtocol

    public init(_ searchDataService: any SearchDataServiceProtocol) {
        self.searchDataService = searchDataService
    }

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