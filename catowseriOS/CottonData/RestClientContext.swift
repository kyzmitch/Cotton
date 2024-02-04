//
//  RestClientContext.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/21/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation
import CottonRestKit
import ReactiveSwift
import Combine
import CottonBase
import ReactiveHttpKit
import BrowserNetworking
import AutoMockable

// swiftlint:disable comment_spacing
//sourcery: associatedtype = "R: ResponseType"
//sourcery: associatedtype = "S: ServerDescription"
//sourcery: associatedtype = "RA: NetworkReachabilityAdapter where RA.Server == S"
//sourcery: associatedtype = "E: JSONRequestEncodable"
//sourcery: associatedtype = "C: RestInterface where C.Reachability == RA, C.Encoder == E"
//sourcery: typealias = "Response = R"
//sourcery: typealias = "Server = S"
//sourcery: typealias = "ReachabilityAdapter = RA"
//sourcery: typealias = "Encoder = E"
//sourcery: typealias = "Client = C"
public protocol RestClientContext: AnyObject, AutoMockable {
    // swiftlint:enable comment_spacing
    associatedtype Response: ResponseType
    associatedtype Server: ServerDescription
    associatedtype ReachabilityAdapter: NetworkReachabilityAdapter where ReachabilityAdapter.Server == Server
    associatedtype Encoder: JSONRequestEncodable
    associatedtype Client: RestInterface where Client.Reachability == ReachabilityAdapter, Client.Encoder == Encoder

    /// Alias for a ReactiveSwift type with specific types in place of generics
    typealias Observer = Signal<Response, HttpError>.Observer
    /// Alias for a real type, no need to hide it under protocol
    typealias ObserverWrapper = RxObserverWrapper<Response, Server, Observer>
    /// Alias for a real type, no need to hide it under protocol
    typealias HttpKitRxSubscriber = RxSubscriber<Response, Server, ObserverWrapper>
    /// Alias for a real type, no need to hide it under protocol
    typealias HttpKitSubscriber = Sub<Response, Server>

    var client: Client { get }
    var rxSubscriber: HttpKitRxSubscriber { get }
    var subscriber: HttpKitSubscriber { get }

    init(_ client: Client,
         _ rxSubscriber: HttpKitRxSubscriber,
         _ subscriber: HttpKitSubscriber)
}
