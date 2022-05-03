//
//  URLInfo+Extension.swift
//  catowser
//
//  Created by Andrei Ermoshin on 5/3/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CoreHttpKit

extension URLInfo {
    func withDifferentPathForSameIp(url: URL) -> URLInfo {
        /// Call this function only after checking that `url.host` is IP address.
        guard url.hasIPHost else {
            return self
        }
        guard ipAddressString == url.host else {
            return self
        }
        // need to update URL without changing host from domain name to ip address
        let newComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard var components = newComponents else { return self }
        components.host = domainName.rawString
        guard let updatedURL = components.url else { return self }
        
        return URLInfo(scheme: .https,
                       remainingURLpart: updatedURL.path,
                       domainName: domainName,
                       ipAddress: ipAddressString)
    }
    
    func withDifferentPathForSameHost(url: URL) -> URLInfo {
        guard !url.hasIPHost else {
            return self
        }
        guard domainName.rawString == url.host else {
            return self
        }
        return URLInfo(scheme: .https,
                       remainingURLpart: url.path,
                       domainName: domainName,
                       ipAddress: ipAddressString)
    }

    
    var platformURL: URL {
        guard let platformURL = URL(string: url) else {
            // This shouldn't fail
            assertionFailure("Failed to convert kotlin URL to platform type")
            // swiftlint:disable:next force_unwrapping
            return URL(string: "")!
        }
        return platformURL
    }
    
    func sameHost(with url: URL) -> Bool {
        let isSameHost: Bool
        if url.hasIPHost {
            isSameHost = ipAddressString == url.host
        } else {
            isSameHost = domainName.rawString == url.host
        }
        return isSameHost
    }

}
