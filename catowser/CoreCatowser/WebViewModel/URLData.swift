//
//  URLData.swift
//  catowser
//
//  Created by Andrei Ermoshin on 8/6/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import CoreHttpKit

enum URLData {
    case url(URL)
    case info(URLInfo)
    
    func updateWith(ip: String) -> URLInfo {
        switch self {
        case .url(let uRL):
            // swiftlint:disable:next force_unwrapping
            return URLInfo(uRL)!.withIPAddress(ipAddress: ip)
        case .info(let uRLInfo):
            return uRLInfo.withIPAddress(ipAddress: ip)
        }
    }
    
    /// Returns an URL info even if internally we have URL
    var info: URLInfo {
        switch self {
        case .url(let uRL):
            // swiftlint:disable:next force_unwrapping
            return URLInfo(uRL)!
        case .info(let uRLInfo):
            return uRLInfo
        }
    }
    
    /// Returns url with a domain name in host property of URL.
    /// Platform URL is always present.
    var platformURL: URL {
        switch self {
        case .url(let uRL):
            return uRL
        case .info(let uRLInfo):
            return uRLInfo.platformURL
        }
    }
    
    /// Could return URL with an ip address instead of a domain name
    /// Probably not needed property.
    var urlWithResolvedDomainName: URL {
        switch self {
        case .url(let uRL):
            return uRL
        case .info(let uRLInfo):
            // swiftlint:disable:next force_unwrapping
            return URL(string: uRLInfo.urlWithIPaddressWithoutPort())!
        }
    }
    
    var host: Host {
        switch self {
        case .url(let uRL):
            // swiftlint:disable:next force_unwrapping
            return uRL.kitHost!
        case .info(let uRLInfo):
            return uRLInfo.host()
        }
    }
    
    var hasIPHost: Bool {
        switch self {
        case .url(let uRL):
            return uRL.hasIPHost
        case .info(let uRLInfo):
            return uRLInfo.ipAddressString != nil
        }
    }
    
    func sameHost(with url: URL) -> Bool {
        switch self {
        case .url(let uRL):
            return uRL.host == url.host
        case .info(let uRLInfo):
            return uRLInfo.sameHost(with: url)
        }
    }
    
    var ipAddress: String? {
        switch self {
        case .url(let uRL):
            return uRL.hasIPHost ? uRL.host : nil
        case .info(let uRLInfo):
            return uRLInfo.ipAddressString
        }
    }
}

extension URLData: Equatable {
    public static func == (lhs: URLData, rhs: URLData) -> Bool {
        switch (lhs, rhs) {
        case (.url(let lUrl), .url(let rUrl)):
            return lUrl == rUrl
        case (.info(let lInfo), .info(let rInfo)):
            return lInfo == rInfo
        default:
            return false
        }
    }
}

extension URLData: CustomStringConvertible {
    var description: String {
        switch self {
        case .url(let url):
            return "url (\(url.absoluteString)"
        case .info(let urlInfo):
            return """
info:\
 -url: \(urlInfo.platformURL.absoluteString)\
 -ip: \(urlInfo.ipAddressString ?? "none")
"""
        }
    }
}
