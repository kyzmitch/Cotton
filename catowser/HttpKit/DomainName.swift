//
//  DomainName.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/26/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

public struct DomainName {
    public let string: String
    
    /// https://developers.google.com/speed/public-dns/docs/doh/json
    // swiftlint:disable:next cyclomatic_complexity
    public init(_ name: String) throws {
        // Invalid names like .example.com, example..com or empty string get 400 Bad Request.
        
        guard !name.isEmpty else {
            throw DomainNameError.emptyString
        }
        
        if let first = name.first, first == "." {
            throw DomainNameError.dotAtBeginning
        }
        if name.contains("..") {
            throw DomainNameError.doubleDots
        }
        // name: The length (after replacing backslash escapes) must be
        // between 1 and 253 (ignoring an optional trailing dot if present).
        
        let nLenght = name.count
        guard (1...253).contains(nLenght) else {
            throw DomainNameError.wrongLength(nLenght)
        }
        
        // All labels (parts of the name betweendots) must be 1 to 63 bytes long.
        let parts = name.split(separator: ".")
        for part in parts {
            guard let partData = part.data(using: .ascii) else {
                continue
            }
            guard (1...63).contains(partData.count) else {
                throw DomainNameError.wrongPartSize(partData.count)
            }
        }
        
        // Non-ASCII characters should be punycoded (xn--qxam, not ελ).
        var containsNonASCII = false
        for character in name {
            // CharacterSet.urlHostAllowed
            guard character.asciiValue != nil else {
                containsNonASCII = true
                break
            }
        }
        
        if containsNonASCII {
            let fixedName =  name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            guard let fixed = fixedName else {
                throw DomainNameError.punycodingFailed
            }
            self.string = fixed
        } else {
            self.string = name
        }
    }
}

public enum DomainNameError: Error {
    case wrongLength(Int)
    case wrongLabels
    case invalidName
    case emptyString
    case dotAtBeginning
    case doubleDots
    case wrongPartSize(Int)
    case punycodingFailed
}
