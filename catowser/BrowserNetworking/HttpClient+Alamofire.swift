//
//  HttpClient+Alamofire.swift
//  BrowserNetworking
//
//  Created by Andrei Ermoshin on 1/25/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import HttpKit
import ReactiveSwift
import CoreHttpKit

/// This typealias could be an issue, because the same defined in ReactiveSwift HttpClient+RxSwift.swift
public typealias RxProducer<R: ResponseType> = SignalProducer<R, HttpKit.HttpError>
/// Shorter name
public typealias RxSub<R, S, O: RxInterface> = HttpKit.RxSubscriber<R, S, O> where O.Observer.Response == R, O.Server == S
/// Shorter name for the subscriber type without dependencies
public typealias Sub<R: ResponseType, S: ServerDescription> = HttpKit.Subscriber<R, S>

extension HttpKit.Client {
    public func makePublicRequest<T, B: HTTPRxAdapter>(for endpoint: Endpoint,
                                                       transport adapter: B)
    where B.Response == T, B.Server == Server {
        makeRxRequest(for: endpoint, withAccessToken: nil, transport: adapter)
    }
    
    public func makeAuthorizedRequest<T, B: HTTPRxAdapter>(for endpoint: Endpoint,
                                                           withAccessToken accessToken: String,
                                                           transport adapter: B)
    where B.Response == T, B.Server == Server {
        makeRxRequest(for: endpoint, withAccessToken: accessToken, transport: adapter)
    }
    
    public func rxMakePublicRequest<T, B: HTTPRxAdapter, RX>(for endpoint: Endpoint,
                                                             transport adapter: B,
                                                             subscriber: HttpKit.RxSubscriber<T, Server, RX>) -> RxProducer<T>
    where B.Response == T, B.Server == Server, B.ObserverWrapper == RX {
        let producer = rxMakeRequest(for: endpoint,
                                        withAccessToken: nil,
                                        transport: adapter,
                                        subscriber: subscriber)
        return producer
    }
    
    public func rxMakeAuthorizedRequest<T, B: HTTPRxAdapter, RX>(for endpoint: Endpoint,
                                                                 withAccessToken accessToken: String,
                                                                 transport adapter: B,
                                                                 subscriber: RxSub<T, Server, RX>) -> RxProducer<T>
    where B.Response == T, B.Server == Server, B.ObserverWrapper == RX {
        let producer = rxMakeRequest(for: endpoint,
                                        withAccessToken: accessToken,
                                        transport: adapter,
                                        subscriber: subscriber)
        return producer
    }
    
    public func cMakePublicRequest<T, B: HTTPAdapter>(for endpoint: Endpoint,
                                                      transport adapter: B,
                                                      subscriber: Sub<T, Server>) -> ResponseFuture<T>
    where B.Response == T, B.Server == Server {
        let future = cMakeRequest(for: endpoint,
                                  withAccessToken: nil,
                                  transport: adapter,
                                  subscriber: subscriber)
        return future
    }
    
    public func cMakeAuthorizedRequest<T, B: HTTPAdapter>(for endpoint: Endpoint,
                                                          withAccessToken accessToken: String,
                                                          transport adapter: B,
                                                          subscriber: Sub<T, Server>) -> ResponseFuture<T>
    where B.Response == T, B.Server == Server {
        let future = cMakeRequest(for: endpoint,
                                  withAccessToken: accessToken,
                                  transport: adapter,
                                  subscriber: subscriber)
        return future
    }
}
