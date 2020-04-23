//
//  URLIpInfo.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 3/20/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation

public struct URLIpInfo {
    var internalUrl: URL
    /// IP address for a host after using DNS request
    public var ipAddress: String?
    public let host: HttpKit.Host
    
    public init?(_ url: URL) {
        guard let host = url.kitHost else {
            return nil
        }
        self.host = host
        internalUrl = url
        ipAddress = nil
    }
    
    public init(_ url: URL, _ host: HttpKit.Host) {
        self.host = host
        internalUrl = url
        ipAddress = nil
    }
    
    /// Automatically provides URL with ip address instead of host when it is available
    public var url: URL {
        guard let ip = ipAddress else {
            return internalUrl
        }
        guard var components = URLComponents(url: internalUrl, resolvingAgainstBaseURL: true) else {
            return internalUrl
        }
        components.host = ip
        guard let clearURL = components.url else {
            return internalUrl
        }
        return clearURL
    }
    
    public var domainURL: URL {
        return internalUrl
    }
    
    public mutating func updateURLForSameIP(url: URL) {
        guard ipAddress == url.host else {
            return
        }
        internalUrl = url
    }
    
    public mutating func updateURLForSameHost(url: URL) {
        guard host.rawValue == url.host else {
            return
        }
        internalUrl = url
    }
    
    public func sameHost(with url: URL) -> Bool {
        let isSameHost: Bool
        if url.hasIPHost {
            isSameHost = ipAddress == url.host
        } else {
            isSameHost = host.rawValue == url.host
        }
        return isSameHost
    }
}
