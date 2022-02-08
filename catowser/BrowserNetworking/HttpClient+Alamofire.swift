//
//  HttpClient+Alamofire.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 1/25/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import HttpKit
import ReactiveSwift

extension HttpKit.Client {
    public func makePublicRequest<T, B: HTTPNetworkingBackend>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                               networkingBackend: B) where B.TYPE == T {
        makeCleanRequest(for: endpoint, withAccessToken: nil, networkingBackend: networkingBackend)
    }
    
    public func makeAuthorizedRequest<T, B: HTTPNetworkingBackend>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                                   withAccessToken accessToken: String,
                                                                   networkingBackend: B) where B.TYPE == T {
        makeCleanRequest(for: endpoint, withAccessToken: accessToken, networkingBackend: networkingBackend)
    }
    
    public func rxMakePublicRequest<T, B: HTTPNetworkingBackend>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                                 networkingBackend: B) -> SignalProducer<T, HttpKit.HttpError> where B.TYPE == T {
        let producer = rxMakeRequest(for: endpoint, withAccessToken: nil, networkingBackend: networkingBackend)
        return producer
    }
    
    public func rxMakeAuthorizedRequest<T, B: HTTPNetworkingBackend>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                                     withAccessToken accessToken: String,
                                                                     networkingBackend: B) -> SignalProducer<T, HttpKit.HttpError> where B.TYPE == T {
        let producer = rxMakeRequest(for: endpoint, withAccessToken: accessToken, networkingBackend: networkingBackend)
        return producer
    }
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func cMakePublicRequest<T, B: HTTPNetworkingBackend>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                                networkingBackend: B) -> ResponseFuture<T> where B.TYPE == T {
        let future = cMakeRequest(for: endpoint,
                                     withAccessToken: nil,
                                     networkingBackend: networkingBackend)
        return future
    }
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func cMakeAuthorizedRequest<T, B: HTTPNetworkingBackend>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                                    withAccessToken accessToken: String,
                                                                    networkingBackend: B) -> ResponseFuture<T> where B.TYPE == T {
        let future = cMakeRequest(for: endpoint,
                                     withAccessToken: accessToken,
                                     networkingBackend: networkingBackend)
        return future
    }
}
