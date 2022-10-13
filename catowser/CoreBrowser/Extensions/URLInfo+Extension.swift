//
//  URLInfo+Extension.swift
//  catowser
//
//  Created by Andrei Ermoshin on 5/3/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CoreHttpKit

public extension URLInfo {
    private func withDifferentPathForSameIp(url: URL) -> URLInfo {
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
                       path: updatedURL.path,
                       query: updatedURL.query,
                       domainName: domainName,
                       ipAddress: ipAddressString)
    }
    
    private func withDifferentPathForSameHost(url: URL) -> URLInfo {
        guard !url.hasIPHost else {
            return self
        }
        guard domainName.rawString == url.host else {
            return self
        }
        return URLInfo(scheme: .https,
                       path: url.path,
                       query: url.query,
                       domainName: domainName,
                       ipAddress: ipAddressString)
    }

    /// Returns an URL with host property set to domain name even if ip address is available
    var platformURL: URL {
        guard let platformURL = URL(string: urlWithoutPort) else {
            // This shouldn't fail
            assertionFailure("Failed to convert kotlin URL to platform type")
            // swiftlint:disable:next force_unwrapping
            return URL(string: "")!
        }
        return platformURL
    }
    
    /// Returns an URL with ip address in place of host
    var urlWithResolvedDomainName: URL {
        // swiftlint:disable:next force_unwrapping
        return URL(string: urlWithIPaddressWithoutPort())!
    }
    
    /// Constructs a URLRequest depending on current host
    var urlRequest: URLRequest {
        let requestedURL: URL
        if ipAddressString != nil {
            requestedURL = urlWithResolvedDomainName
        } else {
            requestedURL = platformURL
        }
        let request = URLRequest(url: requestedURL)
        return request
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
    
    convenience init?(_ url: URL) {
        guard !url.hasIPHost else {
            // Need to have domain name to create url info
            return nil
        }
        guard let hostString = url.host,
              let schemeString = url.scheme,
              let domain = try? DomainName(input: hostString) else {
            return nil
        }
        let scheme: HttpScheme = .companion.create(rawString: schemeString) ?? HttpScheme.https
        self.init(scheme: scheme, path: url.path, query: url.query, domainName: domain, ipAddress: nil)
    }
    
    func withSimilar(_ newURL: URL) -> URLInfo? {
        if newURL.hasIPHost {
            return withDifferentPathForSameIp(url: newURL)
        } else if sameHost(with: newURL) {
            return withDifferentPathForSameHost(url: newURL)
        } else if let createdURLinfo = URLInfo(newURL) {
            // if user moves from one host (search engine)
            // to different (specific website)
            // need to update host completely
            return createdURLinfo
        } else {
            assertionFailure("Impossible case with new URL: \(newURL)")
            return nil
        }
    }
}

extension URLInfo: CustomDebugStringConvertible {
    public override var debugDescription: String {
        return "url[\(platformURL.absoluteString)],ip[\(ipAddressString ?? "none")]"
    }
}
