//
//  HttpClient.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/11/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import Alamofire
import ReactiveSwift

/// Main namespace for Kit
public enum HttpKit {}

extension HttpKit {
    public class Client<Server: ServerDescription> {
        private let server: Server
        
        private let connectivityManager: NetworkReachabilityManager?
        
        private let httpTimeout: TimeInterval
        
        private lazy var hostListener: Alamofire.NetworkReachabilityManager.Listener = { [weak self] status in
            guard let self = self else {
                return
            }
            // TODO: set connectionStateStream.value
        }
        
        public init(server: Server, httpTimeout: TimeInterval = 60) {
            self.server = server
            self.httpTimeout = httpTimeout
            
            if let manager = NetworkReachabilityManager(host: server.hostString) {
                connectivityManager = manager
            } else if let manager = NetworkReachabilityManager() {
                connectivityManager = manager
            } else {
                connectivityManager = nil
                assertionFailure("No connectivity manager for: \(server.hostString)")
            }
            
            connectivityManager?.listener = hostListener
            _ = connectivityManager?.startListening()
        }
        
        private func makeRequest<T: Decodable>(for endpoint: Endpoint<T, Server>,
                                               withAccessToken accessToken: String?,
                                               responseType: T.Type) -> SignalProducer<T, HttpError> {
            let producer = SignalProducer<T, HttpError>.init { [weak self] (observer, _) in
                guard let self = self else {
                    observer.send(error: .zombySelf)
                    return
                }
                guard let url = endpoint.url(self.server) else {
                    observer.send(error: .failedConstructUrl)
                    return
                }
                
                var httpRequest = URLRequest(url: url,
                                             cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                             timeoutInterval: self.httpTimeout)
                httpRequest.httpMethod = endpoint.method.rawValue
                // httpRequest.allHTTPHeaderFields = endpoint.headers
                
                
                observer.sendCompleted()
            }
            return producer
        }
        
        func makePublicRequest<T: Decodable>(for endpoint: Endpoint<T, Server>,
                                             responseType: T.Type) -> SignalProducer<T, HttpError> {
            let producer = makeRequest(for: endpoint, withAccessToken: nil, responseType: responseType)
            return producer
        }
        
        func makeAuthorizedRequest<T: Decodable>(for endpoint: Endpoint<T, Server>,
                                                 withAccessToken accessToken: String,
                                                 responseType: T.Type) -> SignalProducer<T, HttpError> {
            let producer = makeRequest(for: endpoint, withAccessToken: accessToken, responseType: responseType)
            return producer
        }
    }
}
