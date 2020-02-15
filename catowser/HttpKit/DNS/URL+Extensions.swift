//
//  URL+Extensions.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 2/10/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import ReactiveSwift
import Network

public enum DnsError: LocalizedError {
    case zombieSelf
    case httpError(HttpKit.HttpError)
    case notHttpScheme
    case noHost
    case urlComponentsFail
    case urlHostReplaceFail
}

public typealias HostProducer = SignalProducer<String, DnsError>
public typealias UrlConvertProducer = SignalProducer<URL, DnsError>

public extension URL {
    var rxHttpHost: HostProducer {
        guard let scheme = scheme, (scheme == "http" || scheme == "https") else {
            return .init(error: .notHttpScheme)
        }
        
        guard let host = host else {
            return .init(error: .noHost)
        }
        
        return .init(value: host)
    }
    
    func updateHost(with ipAddress: String) -> UrlConvertProducer {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return .init(error: .urlComponentsFail)
        }
        components.host = ipAddress
        guard let clearURL = components.url else {
            return .init(error: .urlHostReplaceFail)
        }
        return .init(value: clearURL)
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
    
    var isAppleMapsURL: Bool {
        if scheme == "http" || scheme == "https" {
            if host == "maps.apple.com" && query != nil {
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
}
