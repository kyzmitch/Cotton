//
//  Host.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 3/29/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation

extension HttpKit {
    public struct Host: RawRepresentable, Equatable {
        /// Use host name as a `rawValue`
        public init?(rawValue: String) {
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
        
        /// Use url with domain name, it's not allowed to use url with ip address
        public init?(url: URL) {
            guard !url.hasIPHost else {
                return nil
            }
            guard let host = url.host else {
                return nil
            }
            self.rawValue = host
        }
        
        /// Host/Domain name
        public let rawValue: String
        public typealias RawValue = String
        
        /// Should return *.apple.com for m.apple.com
        public var wildcardName: String {
            return "*.\(onlySecondLevelDomain)"
        }
        
        /// Custom name to fix e.g. google.com when certificate from google only has www.google.com DNS name in it
        /// Not sure why and how auth challenge was made before that
        public var wwwName: String {
            return "www.\(onlySecondLevelDomain)"
        }
        
        public var onlySecondLevelDomain: String {
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
        
        public func isSimilar(with host: String) -> Bool {
            return host.contains(rawValue) || rawValue.contains(host) || host == rawValue
        }
    }
}

public func == (lhs: HttpKit.Host, rhs: String) -> Bool {
    return lhs.rawValue == rhs
}
