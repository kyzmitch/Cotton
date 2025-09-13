//
//  URL+Rx.swift
//  CottonReactiveRestKit
//
//  Created by Andrei Ermoshin on 2/12/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

@preconcurrency import ReactiveSwift
import CottonRestKit
import Foundation

/// Reactive reducer which returns host or DNS error
public typealias HostProducer = SignalProducer<String, DnsError>
/// Reactive reducer which returns resolved URL with a host or an error
public typealias ResolvedURLProducer = SignalProducer<URL, DnsError>

extension URL {
    /// Not required to be public
    public var rxHttpHost: HostProducer {
        guard let scheme = scheme, (scheme == "http" || scheme == "https") else {
            return .init(error: .notHttpScheme)
        }

        guard let host = host else {
            return .init(error: .noHost)
        }

        return .init(value: host)
    }

    /// Reactive update to the host
    public func rxUpdatedHost(with ipAddress: String) -> ResolvedURLProducer {
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
