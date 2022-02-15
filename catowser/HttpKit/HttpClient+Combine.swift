//
//  HttpClient+Combine.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 4/28/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
#if canImport(Combine)
import Combine
#endif

extension HttpKit.Client {
    public typealias ResponseFuture<T> = Publishers.HandleEvents<Deferred<Future<T, HttpKit.HttpError>>>
    
    public func cMakeRequest<T, B: HTTPRxAdapter, RX>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                withAccessToken accessToken: String?,
                                                transport adapter: B,
                                                _ subscriber: RxSubscriber<T, Server, RX>) -> ResponseFuture<T>
    where B.Response == T, B.Server == Server, B.ObserverWrapper == RX {
        return Combine.Deferred {
            let subject: Future<T, HttpKit.HttpError> = .init { [weak self] (promise) in
                guard let self = self else {
                    promise(.failure(.zombieSelf))
                    return
                }
                
                adapter.transferToCombineState(promise, endpoint)
                subscriber.insert(adapter.handlerType)
                self.makeRxRequest(for: endpoint, withAccessToken: accessToken, transport: adapter)
            }
            return subject
        }.handleEvents(receiveCompletion: { [weak subscriber, weak adapter] _ in
            guard let adapter = adapter else {
                return
            }
            subscriber?.remove(adapter.handlerType)
        })
    }
}
