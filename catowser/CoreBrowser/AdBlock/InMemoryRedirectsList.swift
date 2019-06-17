//
//  InMemoryRedirectsList.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 6/17/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

/// Non mutable data structure to store and provide fast search for domains which should be protected from redirects
public final class InMemoryRedirectsList {
    public static let shared = InMemoryRedirectsList()
    fileprivate let storageBlack: Trie
    fileprivate let storageWhite: Trie
    fileprivate let filenameBlack = "redirects_black_list"
    fileprivate let filenameWhite = "redirects_white_list"
    
    private init() {
        storageBlack = Trie()
        storageWhite = Trie()
        
        let bundle = Bundle(for: InMemoryRedirectsList.self)
        guard let filePathBlack = bundle.path(forResource: filenameBlack, ofType: "txt") else {
            assertionFailure("Failed to find \"\(filenameBlack)\" file in framework bundle")
            return
        }
        
        do {
            let blackList: [String] = try String(contentsOfFile: filePathBlack).components(separatedBy: "\n")
            blackList.forEach { self.storageBlack.insert(word: $0) }
        } catch {
            assertionFailure("Failed to create string from black file")
        }
        
        guard let filePathWhite = bundle.path(forResource: filenameWhite, ofType: "txt") else {
            assertionFailure("Failed to find \"\(filenameWhite)\" file in framework bundle")
            return
        }
        
        do {
            let whiteList: [String] = try String(contentsOfFile: filePathWhite).components(separatedBy: "\n")
            whiteList.forEach { self.storageWhite.insert(word: $0) }
        } catch {
            assertionFailure("Failed to create string from white file")
        }
    }
    
    public func isBlacklisted(_ host: String) -> Bool {
        return storageBlack.contains(word: host)
    }
    
    public func isAllowed(_ host: String) -> Bool {
        return storageWhite.contains(word: host)
    }
}
