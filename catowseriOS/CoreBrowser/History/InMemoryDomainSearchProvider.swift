//
//  InMemoryDomainSearchProvider.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 11/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import CottonBase

@globalActor
public final class InMemoryDomainSearchProvider {
    public static let shared = Provider()
    
    public actor Provider {
        fileprivate let storage: Trie
        fileprivate let filename = "topdomains"

        init() {
            storage = Trie()
            let bundle = Bundle(for: Provider.self)
            
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

extension InMemoryDomainSearchProvider.Provider: DomainsHistory {
    /// TODO: this is actually must be isolated, temporarily add to fix compiler issue
    nonisolated public func remember(host: CottonBase.Host) {
        storage.insert(word: host.rawString)
        if let withoutWww = host.rawString.withoutPrefix("www.") {
            storage.insert(word: withoutWww)
        }
    }
}

extension InMemoryDomainSearchProvider.Provider: KnownDomainsSource {
    /// TODO: this is actually must be isolated, temporarily add to fix compiler issue
    nonisolated public func domainNames(whereURLContains filter: String) -> [String] {
        let words: [String] = storage.findWordsWithPrefix(prefix: filter)
        return words
    }
}
