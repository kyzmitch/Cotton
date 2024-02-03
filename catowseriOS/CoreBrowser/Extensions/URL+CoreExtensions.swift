//
//  URL+CoreExtensions.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 3/31/20.
//  Copyright © 2020 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation
import Network
import CottonBase

public extension URL {
    var isAppleMapsURL: Bool {
        if scheme == "http" || scheme == "https" {
            if host == "maps.apple.com" {
                // Not checking query != nil because https://maps.apple.com/go won't work
                return true
            }
        }
        return false
    }

    var isStoreURL: Bool {
        if scheme == "http" || scheme == "https" || scheme == "itms-apps" {
            if host == "itunes.apple.com" {
                return true
            }
        }
        return false
    }
    
    var hasIPv4Host: Bool {
        guard let actualHost = host else {
            return false
        }
        guard IPv4Address(actualHost) != nil else {
            return false
        }
        
        return true
    }
    
    var hasIPv6Host: Bool {
        guard let actualHost = host else {
            return false
        }
        guard IPv6Address(actualHost) != nil else {
            return false
        }
        
        return true
    }
    
    var hasIPHost: Bool {
        return hasIPv4Host || hasIPv6Host
    }
    
    init?(faviconIPInfo: URLInfo) {
        guard let faviconURLFromIp = faviconIPInfo.faviconURLFromIp else {
            return nil
        }
        self.init(string: faviconURLFromIp)
    }
}
