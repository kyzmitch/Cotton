//
//  HttpClient+Alamofire.swift
//  BrowserNetworking
//
//  Created by Andrei Ermoshin on 1/25/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import HttpKit
import ReactiveSwift

public typealias RxProducer<R: ResponseType> = SignalProducer<R, HttpKit.HttpError>

extension HttpKit.Client {
    public func makePublicRequest<T, B: HTTPRxAdapter>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                     transportAdapter: B) where B.Response == T, B.Server == Server {
        makeRxRequest(for: endpoint, withAccessToken: nil, transport: transportAdapter)
    }
    
    public func makeAuthorizedRequest<T, B: HTTPRxAdapter>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                         withAccessToken accessToken: String,
                                                         transportAdapter: B) where B.Response == T, B.Server == Server {
        makeRxRequest(for: endpoint, withAccessToken: accessToken, transport: transportAdapter)
    }
    
    public func rxMakePublicRequest<T, B: HTTPRxAdapter, RX>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                             transport adapter: B,
                                                             _ subscriber: RxSubscriber<T, Server, RX>) -> RxProducer<T>
                                                             where B.Response == T, B.Server == Server, B.ObserverWrapper == RX {
        let producer = rxMakeRequest(for: endpoint,
                                        withAccessToken: nil,
                                        transport: adapter,
                                        subscriber)
        return producer
    }
    
    public func rxMakeAuthorizedRequest<T, B: HTTPRxAdapter, RX>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                                 withAccessToken accessToken: String,
                                                                 transport adapter: B,
                                                                 _ subscriber: RxSubscriber<T, Server, RX>) -> RxProducer<T>
                                                                 where B.Response == T, B.Server == Server, B.ObserverWrapper == RX {
        let producer = rxMakeRequest(for: endpoint,
                                        withAccessToken: accessToken,
                                        transport: adapter,
                                        subscriber)
        return producer
    }
    
    public func cMakePublicRequest<T, B: HTTPRxAdapter, RX>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                       transport adapter: B,
                                                       _ subscriber: RxSubscriber<T, Server, RX>) -> ResponseFuture<T>
    where B.Response == T, B.Server == Server, B.ObserverWrapper == RX {
        // TODO: Use HTTPAdapter to remove RX dependency for Combine interfaces
        let future = cMakeRequest(for: endpoint,
                                     withAccessToken: nil,
                                     transport: adapter,
                                     subscriber)
        return future
    }
    
    public func cMakeAuthorizedRequest<T, B: HTTPRxAdapter, RX>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                           withAccessToken accessToken: String,
                                                           transport adapter: B,
                                                           _ subscriber: RxSubscriber<T, Server, RX>) -> ResponseFuture<T>
    where B.Response == T, B.Server == Server, B.ObserverWrapper == RX {
        // TODO: Use HTTPAdapter to remove RX dependency for Combine interfaces
        let future = cMakeRequest(for: endpoint,
                                     withAccessToken: accessToken,
                                     transport: adapter,
                                     subscriber)
        return future
    }
}
