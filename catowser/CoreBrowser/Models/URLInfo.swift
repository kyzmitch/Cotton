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
    public let host: String
    
    public init?(_ url: URL) {
        guard let host = url.host else {
            return nil
        }
        self.host = host
        internalUrl = url
        ipAddress = nil
    }
    
    public init(_ url: URL, _ host: String) {
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
    
    public mutating func update(url: URL) {
        guard url.host == host else {
            return
        }
        internalUrl = url
    }
}
