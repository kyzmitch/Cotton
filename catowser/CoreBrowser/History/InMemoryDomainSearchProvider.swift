//
//  InMemoryDomainSearchProvider.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 11/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

public final class InMemoryDomainSearchProvider {
    public static let shared = InMemoryDomainSearchProvider()
    
    fileprivate let storage: Trie
    fileprivate let topDomains: [String]

    private init() {
        storage = Trie()

        guard let bundle = Bundle(identifier: "ae.CoreBrowser") else {
            assertionFailure("Bundle id was changed")
            topDomains = [String]()
            return
        }

        guard let filePath = bundle.path(forResource: "topdomains", ofType: "txt") else {
            assertionFailure("Failed to find \"topdomains\" file in framework bundle")
            topDomains = [String]()
            return
        }

        do {
            topDomains = try String(contentsOfFile: filePath).components(separatedBy: "\n")
            topDomains.forEach { self.storage.insert(word: $0) }
        } catch {
            assertionFailure("Failed to create string from file")
            topDomains = [String]()
        }
    }
}

extension InMemoryDomainSearchProvider: DomainsHistory {
    public func domainNames(whereURLContains filter: String) -> [String] {
        let words: [String] = storage.findWordsWithPrefix(prefix: filter)
        return words
    }

    public func rememberDomain(name: String) {
        storage.insert(word: name)
        if let withoutWww = name.withoutPrefix("www.") {
            storage.insert(word: withoutWww)
        }
    }
}
