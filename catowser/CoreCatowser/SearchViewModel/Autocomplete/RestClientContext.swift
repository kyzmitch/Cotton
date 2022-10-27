//
//  RestClientContext.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/21/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import HttpKit
import ReactiveSwift
import Combine
import CoreHttpKit
import ReactiveHttpKit
import BrowserNetworking
import AutoMockable

// swiftlint:disable comment_spacing
//sourcery: associatedtype = "Response: ResponseType"
//sourcery: associatedtype = "Server: ServerDescription"
//sourcery: associatedtype = "ReachabilityAdapter: NetworkReachabilityAdapter"
//sourcery: associatedtype = "Encoder: JSONRequestEncodable"
public protocol RestClientContext: AnyObject, AutoMockable {
    associatedtype Response: ResponseType
    associatedtype Server: ServerDescription
    associatedtype ReachabilityAdapter: NetworkReachabilityAdapter where ReachabilityAdapter.Server == Server
    associatedtype Encoder: JSONRequestEncodable
    
    typealias Observer = Signal<Response, HttpError>.Observer
    typealias ObserverWrapper = RxObserverWrapper<Response, Server, Observer>
    typealias HttpKitRxSubscriber = RxSubscriber<Response, Server, ObserverWrapper>
    typealias HttpKitSubscriber = Sub<Response, Server>
    typealias Client = RestClient<Server, ReachabilityAdapter, Encoder>
    // swiftlint:enable comment_spacing
    
    var client: Client { get }
    var rxSubscriber: HttpKitRxSubscriber { get }
    var subscriber: HttpKitSubscriber { get }
    
    init(_ client: Client,
         _ rxSubscriber: HttpKitRxSubscriber,
         _ subscriber: HttpKitSubscriber)
}
