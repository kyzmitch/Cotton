//
//  URL+Extensions.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 2/10/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import ReactiveSwift

public enum DnsError: LocalizedError {
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
}
