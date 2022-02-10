//
//  HttpClient+RxSwift.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 11/29/21.
//  Copyright © 2021 andreiermoshin. All rights reserved.
//

import Foundation
import ReactiveSwift

extension HttpKit.Client {
    public func rxMakeRequest<T, B: HTTPAdapter>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                 withAccessToken accessToken: String?,
                                                 transportAdapter: B) -> SignalProducer<T, HttpKit.HttpError> where B.TYPE == T, B.SRV == Server {
        let producer: SignalProducer<T, HttpKit.HttpError> = .init { [weak self] (observer, lifetime) in
            guard let self = self else {
                observer.send(error: .zombieSelf)
                return
            }
            
            transportAdapter.transferToRxState(observer, lifetime, endpoint)
            // backendHandlersPool.insert(transportAdapter)
            self.makeCleanRequest(for: endpoint, withAccessToken: accessToken, transportAdapter: transportAdapter)
        }
        
        return producer.on(failed: { error in
            
        }, completed: { [weak self] in
            // self?.backendHandlersPool.remove(transportAdapter)
        })
    }
    
    public func rxMakeVoidRequest<B: HTTPVoidAdapter>(for endpoint: HttpKit.VoidEndpoint<Server>,
                                                      withAccessToken accessToken: String?,
                                                      transportAdapter: B) -> SignalProducer<Void, HttpKit.HttpError> where B.SRV == Server {
        let producer: SignalProducer<Void, HttpKit.HttpError> = .init { [weak self] (observer, lifetime) in
            guard let self = self else {
                observer.send(error: .zombieSelf)
                return
            }
            
            transportAdapter.transferToRxState(observer, lifetime, endpoint)
            self.makeCleanVoidRequest(for: endpoint, withAccessToken: accessToken, transportAdapter: transportAdapter)
        }
        return producer
    }
}
