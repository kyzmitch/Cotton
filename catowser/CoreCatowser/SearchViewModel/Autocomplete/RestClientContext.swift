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

public protocol RestClientContext: AnyObject, AutoMockable {
    associatedtype Response: ResponseType
    associatedtype Server: ServerDescription
    associatedtype ReachabilityAdapter: NetworkReachabilityAdapter where ReachabilityAdapter.Server == Server
    
    typealias Observer = Signal<Response, HttpError>.Observer
    typealias ObserverWrapper = RxObserverWrapper<Response, Server, Observer>
    typealias HttpKitRxSubscriber = RxSubscriber<Response, Server, ObserverWrapper>
    typealias HttpKitSubscriber = Sub<Response, Server>
    typealias Client = RestClient<Server, ReachabilityAdapter>
    
    var client: Client { get }
    var rxSubscriber: HttpKitRxSubscriber { get }
    var subscriber: HttpKitSubscriber { get }
    
    init(_ client: Client,
         _ rxSubscriber: HttpKitRxSubscriber,
         _ subscriber: HttpKitSubscriber)
}
