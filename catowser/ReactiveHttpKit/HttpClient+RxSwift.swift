//
//  HttpClient+RxSwift.swift
//  ReactiveHttpKit
//
//  Created by Andrei Ermoshin on 11/29/21.
//  Copyright © 2021 andreiermoshin. All rights reserved.
//

import HttpKit
import ReactiveSwift

extension HttpKit.Client {
    public func rxMakeRequest<T, B: HTTPAdapter, RX>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                     withAccessToken accessToken: String?,
                                                     transport adapter: B,
                                                     _ subscriber: HttpKit.ClientSubscriber<T, Server, RX>) -> SignalProducer<T, HttpKit.HttpError>
                                                     where B.TYPE == T, B.SRV == Server, B.RXI == RX {
        let producer: SignalProducer<T, HttpKit.HttpError> = .init { [weak self] (observer, lifetime) in
            guard let self = self else {
                observer.send(error: .zombieSelf)
                return
            }
            
            adapter.transferToRxState(observer, lifetime, endpoint)
            subscriber.insert(adapter.handlerType)
            self.makeCleanRequest(for: endpoint, withAccessToken: accessToken, transport: adapter)
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
    
    public func rxMakeVoidRequest<B: HTTPVoidAdapter>(for endpoint: HttpKit.VoidEndpoint<Server>,
                                                      withAccessToken accessToken: String?,
                                                      transport adapter: B) -> SignalProducer<Void, HttpKit.HttpError>
                                                      where B.SRV == Server {
        let producer: SignalProducer<Void, HttpKit.HttpError> = .init { [weak self] (observer, lifetime) in
            guard let self = self else {
                observer.send(error: .zombieSelf)
                return
            }
            
            adapter.transferToRxState(observer, lifetime, endpoint)
            self.makeCleanVoidRequest(for: endpoint, withAccessToken: accessToken, transportAdapter: adapter)
        }
        return producer
    }
}
