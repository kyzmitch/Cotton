//
//  URL+Extensions.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 2/10/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import ReactiveSwift
#if canImport(Combine)
import Combine
#endif
import Network

extension HttpKit {
    public enum DnsError: LocalizedError {
        case zombieSelf
        case httpError(HttpKit.HttpError)
        case notHttpScheme
        case noHost
        case urlComponentsFail
        case urlHostReplaceFail
    }
}

public typealias HostProducer = SignalProducer<String, HttpKit.DnsError>
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
typealias HostPublisher = Result<String, HttpKit.DnsError>.Publisher
public typealias ResolvedURLProducer = SignalProducer<URL, HttpKit.DnsError>
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
typealias ResolvedURLPublisher = Result<URL, HttpKit.DnsError>.Publisher

extension URL {
    public var kitHost: HttpKit.Host? {
        guard let hostString = host else {
            return nil
        }
        
        let value = HttpKit.Host(rawValue: hostString)
        return value
    }
    
    public var rxHttpHost: HostProducer {
        guard let scheme = scheme, (scheme == "http" || scheme == "https") else {
            return .init(error: .notHttpScheme)
        }
        
        guard let host = host else {
            return .init(error: .noHost)
        }
        
        return .init(value: host)
    }
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public var httpHost: AnyPublisher<String, HttpKit.DnsError> {
        guard let scheme = scheme, (scheme == "http" || scheme == "https") else {
            return HostPublisher(.failure(.notHttpScheme)).eraseToAnyPublisher()
        }
        
        guard let host = host else {
            return HostPublisher(.failure(.noHost)).eraseToAnyPublisher()

        }
        
        return HostPublisher(.success(host)).eraseToAnyPublisher()
    }
    
    func rxUpdatedHost(with ipAddress: String) -> ResolvedURLProducer {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return .init(error: .urlComponentsFail)
        }
        components.host = ipAddress
        guard let clearURL = components.url else {
            return .init(error: .urlHostReplaceFail)
        }
        return .init(value: clearURL)
    }
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func updatedHost(with ipAddress: String) -> ResolvedURLPublisher {
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
