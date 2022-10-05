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
    
    func updateWith(ip: String) -> URLInfo? {
        switch self {
        case .url(let uRL):
            return URLInfo(uRL)?.withIPAddress(ipAddress: ip)
        case .info(let uRLInfo):
            return uRLInfo.withIPAddress(ipAddress: ip)
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
    var urlWithResolvedDomainName: URL {
        switch self {
        case .url(let uRL):
            return uRL
        case .info(let uRLInfo):
            // swiftlint:disable:next force_unwrapping
            return URL(string: uRLInfo.urlWithIPaddress())!
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
}

extension URLData: Equatable {}
