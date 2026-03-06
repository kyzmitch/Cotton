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

public final class CreateSearchURLUseCase: CoreUseCase {
    public typealias Input = (source: WebAutoCompletionSource, suggestion: String)
    public typealias Output = URL
    
    private let searchDataService: any SearchDataServiceProtocol

    public init(_ searchDataService: any SearchDataServiceProtocol) {
        self.searchDataService = searchDataService
    }

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