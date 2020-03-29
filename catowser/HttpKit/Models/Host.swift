//
//  Host.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 3/29/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation

extension HttpKit {
    struct Host: RawRepresentable {
        init?(rawValue: String) {
            // https://tools.ietf.org/html/rfc1808#section-2.4
            // temporarily using URL to validate host string
            var components = URLComponents()
            components.scheme = "http"
            components.host = rawValue
            guard components.url != nil else {
                return nil
            }
            self.rawValue = rawValue
        }
        
        init?(url: URL) {
            guard !url.hasIPHost else {
                return nil
            }
            guard let host = url.host else {
                return nil
            }
            self.rawValue = host
        }
        
        let rawValue: String
        typealias RawValue = String
        
        /// Should return *.apple.com for m.apple.com
        var wildcardName: String {
            return "*.\(onlySecondLevelDomain)"
        }
        
        var onlySecondLevelDomain: String {
            var domainComponents = rawValue.split(separator: ".")
            guard domainComponents.count > 1 else {
                return rawValue
            }
            // a top level domain (TLD) – also called a domain name extension – is
            // the letter combination that concludes a web address
            // Of all TLDs, the most famous is .com.
            // swiftlint:disable:next force_unwrapping
            let tld = domainComponents.popLast()!
            // second level domain
            // swiftlint:disable:next force_unwrapping
            let sld = domainComponents.popLast()!
            return "\(sld).\(tld)"
        }
        
    }
}
