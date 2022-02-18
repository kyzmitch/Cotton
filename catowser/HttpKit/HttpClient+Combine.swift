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
    public typealias ResponseFuture<T> = Deferred<Publishers.HandleEvents<Future<T, HttpKit.HttpError>>>
    
    public func cMakeRequest<T, B: HTTPRxAdapter, RX>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                      withAccessToken accessToken: String?,
                                                      transport adapter: B,
                                                      _ subscriber: RxSubscriber<T, Server, RX>) -> ResponseFuture<T>
    where B.Response == T, B.Server == Server, B.ObserverWrapper == RX {
        // Can't use Future without Deferred because
        // a Future will begin executing immediately when you create it.
        return Combine.Deferred {
            let subject: Future<T, HttpKit.HttpError> = .init { [weak self] (promise) in
                guard let self = self else {
                    promise(.failure(.zombieSelf))
                    return
                }
                
                adapter.transferToCombineState(promise, endpoint)
                subscriber.insert(adapter.handlerType)
                // TODO: use makeRequest instead
                self.makeRxRequest(for: endpoint, withAccessToken: accessToken, transport: adapter)
            }
            return subject.handleEvents(receiveCompletion: { [weak subscriber] _ in
                // Must capture `adapter` by strong reference comparing to
                // similar implementation for Rx, because the `adapter` is getting deallocated
                // for Combine implementation for some still unknown reason.
                // Actually we only store handlerType reference types in the ClientSubscriber sets
                // so, actually the first question is why Rx implementation was working
                // because I would expect that adapter is nil and you can't transfer execution back
                // to the handler
                subscriber?.remove(adapter.handlerType)
            })
        }
    }
}
