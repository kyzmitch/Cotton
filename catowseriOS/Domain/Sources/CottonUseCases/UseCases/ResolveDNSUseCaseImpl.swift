//
//  ResolveDNSUseCaseImpl.swift
//  catowser
//
//  Created by Andrei Ermoshin on 7/29/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import CottonSearch
import Foundation

private extension String {
    static let waitingQueueName: String = .queueNameWith(suffix: "dnsResolvingThrottle")
}

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
