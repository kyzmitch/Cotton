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
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public typealias ResponseFuture<T> = Publishers.HandleEvents<Deferred<Future<T, HttpKit.HttpError>>>
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func cMakeRequest<T, B: HTTPAdapter>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                withAccessToken accessToken: String?,
                                                transportAdapter: B) -> ResponseFuture<T> where B.TYPE == T, B.SRV == Server {
        return Combine.Deferred {
            let subject: Future<T, HttpKit.HttpError> = .init { [weak self] (promise) in
                guard let self = self else {
                    promise(.failure(.zombieSelf))
                    return
                }
                
                transportAdapter.transferToCombineState(promise, endpoint)
                // backendHandlersPool.insert(transportAdapter)
                self.makeCleanRequest(for: endpoint, withAccessToken: accessToken, transportAdapter: transportAdapter)
            }
            return subject
        }.handleEvents { [weak self] completion in
            // self?.backendHandlersPool.remove(transportAdapter)
        }
    }
}
