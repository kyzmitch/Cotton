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
            // name: The length (after replacing backslash escapes) must be
            // between 1 and 253 (ignoring an optional trailing dot if present).
            
            let nLenght = name.count
            guard (1...253).contains(nLenght) else {
                throw DomainNameError.wrongLength
            }
            
            // All labels (parts of the name betweendots) must be 1 to 63 bytes long.
            
            // Invalid names like .example.com, example..com or empty string get 400 Bad Request.
            
            // Non-ASCII characters should be punycoded (xn--qxam, not ελ).
            
            self.string = name
        }
    }
}

extension HttpKit {
    public enum DomainNameError: Error {
        case wrongLength
        case wrongLabels
        case invalidName
        
    }
}
