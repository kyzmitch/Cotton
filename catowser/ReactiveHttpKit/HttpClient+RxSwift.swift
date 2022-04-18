//
//  HttpClient+RxSwift.swift
//  ReactiveHttpKit
//
//  Created by Andrei Ermoshin on 11/29/21.
//  Copyright © 2021 andreiermoshin. All rights reserved.
//

import HttpKit
import ReactiveSwift
import CoreHttpKit

/// This typealias could be an issue, because the same defined in BrowserNetworking HttpClient+Alamofire.swift
public typealias RxProducer<R: ResponseType> = SignalProducer<R, HttpKit.HttpError>
public typealias RxVoidProducer = SignalProducer<Void, HttpKit.HttpError>

extension HttpKit.Client {
    public func rxMakeRequest<T, B: HTTPRxAdapter, RX>(for endpoint: Endpoint,
                                                       withAccessToken accessToken: String?,
                                                       transport adapter: B,
                                                       subscriber: HttpKit.RxSubscriber<T, Server, RX>) -> RxProducer<T>
    where B.Response == T, B.Server == Server, B.ObserverWrapper == RX {
        let producer: SignalProducer<T, HttpKit.HttpError> = .init { [weak self] (observer, lifetime) in
            guard let self = self else {
                observer.send(error: .zombieSelf)
                return
            }
            
            adapter.transferToRxState(observer, lifetime, endpoint)
            subscriber.insert(adapter.handlerType)
            self.makeRxRequest(for: endpoint, withAccessToken: accessToken, transport: adapter)
        }
        
        return producer.on(failed: { [weak subscriber] _ in
            subscriber?.remove(adapter.handlerType)
        }, completed: { [weak subscriber, weak adapter] in
            guard let adapter = adapter else {
                return
            }
            subscriber?.remove(adapter.handlerType)
        })
    }
    
    public func rxMakeVoidRequest<B: HTTPRxVoidAdapter, RX>(for endpoint: Endpoint,
                                                            withAccessToken accessToken: String?,
                                                            transport adapter: B,
                                                            subscriber: HttpKit.RxVoidSubscriber<Server, RX>) -> RxVoidProducer
    where B.Server == Server, B.Observer == RX {
        let producer: SignalProducer<Void, HttpKit.HttpError> = .init { [weak self] (observer, lifetime) in
            guard let self = self else {
                observer.send(error: .zombieSelf)
                return
            }
            
            adapter.transferToRxState(observer, lifetime, endpoint)
            subscriber.insert(adapter.handlerType)
            self.makeRxVoidRequest(for: endpoint, withAccessToken: accessToken, transport: adapter)
        }
        return producer.on(failed: { [weak subscriber] _ in
            subscriber?.remove(adapter.handlerType)
        }, completed: { [weak subscriber, weak adapter] in
            guard let adapter = adapter else {
                return
            }
            subscriber?.remove(adapter.handlerType)
        })
    }
}
