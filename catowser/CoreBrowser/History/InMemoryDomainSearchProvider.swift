//
//  InMemoryDomainSearchProvider.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 11/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import HttpKit

public final class InMemoryDomainSearchProvider {
    public static let shared = InMemoryDomainSearchProvider()
    
    fileprivate let storage: Trie
    fileprivate let filename = "topdomains"

    private init() {
        storage = Trie()
        let bundle = Bundle(for: InMemoryDomainSearchProvider.self)
        
        guard let filePath = bundle.path(forResource: filename, ofType: "txt") else {
            assertionFailure("Failed to find \"\(filename)\" file in framework bundle")
            return
        }

        do {
            let topDomains: [String] = try String(contentsOfFile: filePath).components(separatedBy: "\n")
            topDomains.forEach { self.storage.insert(word: $0) }
        } catch {
            assertionFailure("Failed to create string from file")
        }
    }
}

extension InMemoryDomainSearchProvider: DomainsHistory {
    public func domainNames(whereURLContains filter: String) -> [String] {
        let words: [String] = storage.findWordsWithPrefix(prefix: filter)
        return words
    }

    public func remember(domainName: HttpKit.Host) {
        storage.insert(word: domainName.rawValue)
        if let withoutWww = domainName.rawValue.withoutPrefix("www.") {
            storage.insert(word: withoutWww)
        }
    }
}
