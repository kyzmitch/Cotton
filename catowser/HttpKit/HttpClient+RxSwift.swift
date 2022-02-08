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
    private func rxMakeRequest<T, B: HTTPNetworkingBackend>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                            withAccessToken accessToken: String?,
                                                            networkingBackend: B) -> SignalProducer<T, HttpKit.HttpError> where B.TYPE == T {
        let producer: SignalProducer<T, HttpKit.HttpError> = .init { [weak self] (observer, lifetime) in
            guard let self = self else {
                observer.send(error: .zombieSelf)
                return
            }
            
            networkingBackend.transferToRxState(observer, lifetime)
            self.makeCleanRequest(for: endpoint, withAccessToken: accessToken, networkingBackend: networkingBackend)
        }
        
        return producer
    }
    
    func rxMakeVoidRequest(for endpoint: HttpKit.VoidEndpoint<Server>,
                           withAccessToken accessToken: String?,
                           networkingBackend: HTTPNetworkingBackendVoid) -> SignalProducer<Void, HttpKit.HttpError> {
        let producer: SignalProducer<Void, HttpKit.HttpError> = .init { [weak self] (observer, lifetime) in
            guard let self = self else {
                observer.send(error: .zombieSelf)
                return
            }
            
            networkingBackend.transferToRxState(observer, lifetime)
            self.makeCleanVoidRequest(for: endpoint, withAccessToken: accessToken, networkingBackend: networkingBackend)
        }
        return producer
    }
}
