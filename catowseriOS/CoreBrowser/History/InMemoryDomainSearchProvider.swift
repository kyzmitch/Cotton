//
//  InMemoryDomainSearchProvider.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 11/04/2019.
//  Copyright © 2019 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation
import CottonBase

private let filename = "topdomains"

@globalActor
public final class InMemoryDomainSearchProvider {
    public static let shared = StateHolder()

    public actor StateHolder {
        fileprivate let storage: Trie

        init() {
            storage = Trie()
            let bundle = Bundle(for: StateHolder.self)

            guard let filePath = bundle.path(forResource: filename, ofType: "txt") else {
                assertionFailure("Failed to find \"\(filename)\" file in framework bundle")
                return
            }

            do {
                let topDomains: [String] = try String(contentsOfFile: filePath).components(separatedBy: "\n")
                for domain in topDomains {
                    storage.insert(word: domain)
                }
            } catch {
                assertionFailure("Failed to create string from file")
            }
        }
    }
}

extension CottonBase.Host: @unchecked Sendable {}

extension InMemoryDomainSearchProvider.StateHolder: DomainsHistory {
    public func remember(host: CottonBase.Host) async {
        storage.insert(word: host.rawString)
        if let withoutWww = host.rawString.withoutPrefix("www.") {
            storage.insert(word: withoutWww)
        }
    }
}

extension InMemoryDomainSearchProvider.StateHolder: KnownDomainsSource {
    public func domainNames(whereURLContains filter: String) async -> [String] {
        let words: [String] = storage.findWordsWithPrefix(prefix: filter)
        return words
    }
}
