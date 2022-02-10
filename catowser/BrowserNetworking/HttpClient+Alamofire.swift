//
//  HttpClient+Alamofire.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 1/25/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import HttpKit
import ReactiveSwift

public typealias Subscriber<R: ResponseType, S: ServerDescription> = HttpKit.ClientSubscriber<R, S>
public typealias RxProducer<R: ResponseType> = SignalProducer<R, HttpKit.HttpError>

extension HttpKit.Client {
    public func makePublicRequest<T, B: HTTPAdapter>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                     transportAdapter: B) where B.TYPE == T, B.SRV == Server {
        makeCleanRequest(for: endpoint, withAccessToken: nil, transportAdapter: transportAdapter)
    }
    
    public func makeAuthorizedRequest<T, B: HTTPAdapter>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                         withAccessToken accessToken: String,
                                                         transportAdapter: B) where B.TYPE == T, B.SRV == Server {
        makeCleanRequest(for: endpoint, withAccessToken: accessToken, transportAdapter: transportAdapter)
    }
    
    public func rxMakePublicRequest<T, B: HTTPAdapter>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                       transport adapter: B,
                                                       _ subscriber: Subscriber<T, Server>) -> RxProducer<T>
                                                       where B.TYPE == T, B.SRV == Server {
        let producer = rxMakeRequest(for: endpoint,
                                        withAccessToken: nil,
                                        transport: adapter,
                                        subscriber)
        return producer
    }
    
    public func rxMakeAuthorizedRequest<T, B: HTTPAdapter>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                           withAccessToken accessToken: String,
                                                           transport adapter: B,
                                                           _ subscriber: Subscriber<T, Server>) -> RxProducer<T>
                                                           where B.TYPE == T, B.SRV == Server {
        let producer = rxMakeRequest(for: endpoint,
                                        withAccessToken: accessToken,
                                        transport: adapter,
                                        subscriber)
        return producer
    }
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func cMakePublicRequest<T, B: HTTPAdapter>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                      transportAdapter: B) -> ResponseFuture<T> where B.TYPE == T, B.SRV == Server {
        let future = cMakeRequest(for: endpoint,
                                     withAccessToken: nil,
                                     transportAdapter: transportAdapter)
        return future
    }
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func cMakeAuthorizedRequest<T, B: HTTPAdapter>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                          withAccessToken accessToken: String,
                                                          transportAdapter: B) -> ResponseFuture<T> where B.TYPE == T, B.SRV == Server {
        let future = cMakeRequest(for: endpoint,
                                     withAccessToken: accessToken,
                                     transportAdapter: transportAdapter)
        return future
    }
}
