//
//  URL+Extensions.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 2/10/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
#if canImport(Combine)
import Combine
#endif
import Network
import CottonBase

public enum DnsError: LocalizedError {
    case zombieSelf
    case httpError(HttpError)
    case notHttpScheme
    case noHost
    case urlComponentsFail
    case failToGetUrlFromComponents
    case urlHostReplaceFail
    case hostIsNotIpAddress
    
    public var localizedDescription: String {
        switch self {
        case .httpError(let httpErr):
            return "dns err: \(httpErr.localizedDescription)"
        default:
            return "dns err: \(self)"
        }
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
typealias HostPublisher = Result<String, DnsError>.Publisher
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public typealias ResolvedURLPublisher = Result<URL, DnsError>.Publisher

extension URL {
    /// Have to use module name for Host type, becuase for macOS variant there is `Foundation.Host`
    public var kitHost: CottonBase.Host? {
        guard let hostString = host else {
            return nil
        }
        
        return try? Host(input: hostString)
    }
    
    public var httpHost: String? {
        guard let scheme = scheme, (scheme == "http" || scheme == "https") else {
            return nil
        }
        
        return host
    }
    
    /// Not required to be public
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public var cHttpHost: AnyPublisher<String, DnsError> {
        guard let scheme = scheme, (scheme == "http" || scheme == "https") else {
            return HostPublisher(.failure(.notHttpScheme)).eraseToAnyPublisher()
        }
        
        guard let host = host else {
            return HostPublisher(.failure(.noHost)).eraseToAnyPublisher()

        }
        
        return HostPublisher(.success(host)).eraseToAnyPublisher()
    }
    
    public func updatedHost(with ipAddress: String) throws -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            throw DnsError.urlComponentsFail
        }
        components.host = ipAddress
        guard let clearURL = components.url else {
            throw DnsError.failToGetUrlFromComponents
        }
        return clearURL
    }
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func cUpdatedHost(with ipAddress: String) -> ResolvedURLPublisher {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return ResolvedURLPublisher(.failure(.urlComponentsFail))
        }
        components.host = ipAddress
        guard let clearURL = components.url else {
            return ResolvedURLPublisher(.failure(.urlHostReplaceFail))
        }
        return ResolvedURLPublisher(.success(clearURL))
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
}
