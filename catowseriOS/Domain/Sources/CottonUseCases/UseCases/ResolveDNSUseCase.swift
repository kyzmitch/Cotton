//
//  ResolveDNSUseCase.swift
//  CottonData
//
//  Created by Andrey Ermoshin on 27.01.2024.
//  Copyright © 2024 Cotton (former Catowser). All rights reserved.
//

import AutoMockable
import Foundation
import BaseUseCaseKit
import CottonSearch

private extension String {
    static let waitingQueueName: String = .queueNameWith(suffix: "dnsResolvingThrottle")
}

// MARK: - Interface

/// Resolve domain name use case.
/// 
/// Use cases do not hold any mutable state, so that, any of them can be sendable.
public protocol ResolveDNSUseCase: CoreUseCase, AutoMockable, Sendable {
    func execute(input: URL) async throws -> URL
}

// MARK: - Implementation

public final class ResolveDNSUseCaseImpl: ResolveDNSUseCase {
    private let searchDataService: any SearchDataServiceProtocol

    public init(_ searchDataService: any SearchDataServiceProtocol) {
        self.searchDataService = searchDataService
    }

    public func execute(input: URL) async throws -> URL {
        let resolvedURL: URL = try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume(throwing: AppError.zombieSelf)
                return
            }
            searchDataService.sendCommand(
                .resolveDomainNameInURL(UUID(), input),
                nil
            ) { result in
                switch result {
                case .failure(let searchError):
                    continuation.resume(throwing: AppError.searchDataServiceError(searchError))
                case .success(let serviceData):
                    do {
                        continuation.resume(returning: try serviceData.resolvedURL)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
        return resolvedURL
    }
}
