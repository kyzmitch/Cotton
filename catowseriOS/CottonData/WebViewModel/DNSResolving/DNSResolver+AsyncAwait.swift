//
//  DNSResolver+AsyncAwait.swift
//  catowser
//
//  Created by Andrei Ermoshin on 8/6/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

#if swift(>=5.5)

import Foundation

extension DNSResolver {
    @available(swift 5.5)
    @available(macOS 12, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func aaResolveDomainName(_ url: URL) async throws -> URL {
        let response = try await strategy.domainNameResolvingTask(url)
        return response
    }
}

#endif
