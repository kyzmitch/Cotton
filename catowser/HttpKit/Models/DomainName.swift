//
//  DomainName.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/26/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

extension HttpKit {
    public struct DomainName {
        let string: String
        
        /// https://developers.google.com/speed/public-dns/docs/doh/json
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
            
            for character in name {
                if CharacterSet.urlHostAllowed.co
            }
            self.string = name
        }
    }
}

extension HttpKit {
    public enum DomainNameError: Error {
        case wrongLength(Int)
        case wrongLabels
        case invalidName
        case emptyString
        case dotAtBeginning
        case doubleDots
        case wrongPartSize(Int)
    }
}
