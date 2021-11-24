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

fileprivate extension String {
    static let threadName = "Client"
}

extension HttpKit {
    public class Client<Server: ServerDescription> {
        let server: Server
        
        private let connectivityManager: NetworkReachabilityManager?
        
        let sessionTaskHandler: HttpClientSessionTaskDelegate?
        
        let urlSessionHandler: HttpClientUrlSessionDelegate?
        
        private let urlSessionQueue: DispatchQueue = .init(label: "com.ae.HttpKit." + .threadName)
        
        /// Used only for async/await implementation when Alamofire can't be used naturally
        let urlSession: URLSession
        
        let httpTimeout: TimeInterval
        
        public typealias HostNetState = NetworkReachabilityManager.NetworkReachabilityStatus
        
        public let connectionStateStream: MutableProperty<HostNetState>
        
        private lazy var hostListener: Alamofire.NetworkReachabilityManager.Listener = { [weak self] status in
            guard let self = self else {
                return
            }
            self.connectionStateStream.value = status
        }
        
        public init(server: Server, httpTimeout: TimeInterval = 60) {
            self.server = server
            self.httpTimeout = httpTimeout
            let sessionConfiguration = URLSessionConfiguration.default
            urlSessionHandler = .init()
            let operationQueue: OperationQueue = .init()
            operationQueue.underlyingQueue = urlSessionQueue
            urlSession = URLSession(configuration: sessionConfiguration,
                                    delegate: urlSessionHandler,
                                    delegateQueue: operationQueue)
            sessionTaskHandler = .init()
            
            if let manager = NetworkReachabilityManager(host: server.hostString) {
                connectivityManager = manager
            } else if let manager = NetworkReachabilityManager() {
                connectivityManager = manager
            } else {
                connectivityManager = nil
                assertionFailure("No connectivity manager for: \(server.hostString)")
            }
            connectionStateStream = .init(.unknown)
            guard let cManager = connectivityManager else {
                return
            }
            guard cManager.startListening(onUpdatePerforming: hostListener) else {
                print("Connectivity listening failed to start")
                return
            }
        }
        
        private func makeRequest<T: ResponseType>(for endpoint: Endpoint<T, Server>,
                                                  withAccessToken accessToken: String?,
                                                  responseType: T.Type) -> SignalProducer<T, HttpError> {
            let producer: SignalProducer<T, HttpError> = .init { [weak self] (observer, lifetime) in
                guard let self = self else {
                    observer.send(error: .zombieSelf)
                    return
                }
                guard let url = endpoint.url(relatedTo: self.server) else {
                    observer.send(error: .failedConstructUrl)
                    return
                }
                
                let httpRequest: URLRequest
                do {
                    httpRequest = try endpoint.request(url, httpTimeout: self.httpTimeout, accessToken: accessToken)
                } catch let error as HttpError {
                    observer.send(error: error)
                    return
                } catch {
                    observer.send(error: .httpFailure(error: error))
                    return
                }
                
                let codes = T.successCodes
                
                let dataRequest: DataRequest = AF.request(httpRequest)
                dataRequest
                    .validate(statusCode: codes)
                    .responseDecodable(of: responseType,
                                       queue: .main,
                                       decoder: JSONDecoder(),
                                       completionHandler: { (response) in
                        switch response.result {
                        case .success(let value):
                            observer.send(value: value)
                            observer.sendCompleted()
                        case .failure(let error):
                            observer.send(error: .httpFailure(error: error))
                        }
                    })
                
                lifetime.observeEnded({
                    dataRequest.cancel()
                })
            }
            
            return producer
        }
        
        public func makePublicRequest<T: ResponseType>(for endpoint: Endpoint<T, Server>,
                                                       responseType: T.Type) -> SignalProducer<T, HttpError> {
            let producer = makeRequest(for: endpoint, withAccessToken: nil, responseType: responseType)
            return producer
        }
        
        public func makeAuthorizedRequest<T: ResponseType>(for endpoint: Endpoint<T, Server>,
                                                           withAccessToken accessToken: String,
                                                           responseType: T.Type) -> SignalProducer<T, HttpError> {
            let producer = makeRequest(for: endpoint, withAccessToken: accessToken, responseType: responseType)
            return producer
        }
        
        func makeVoidRequest(for endpoint: VoidEndpoint<Server>,
                             withAccessToken accessToken: String?) -> SignalProducer<Void, HttpError> {
            let producer: SignalProducer<Void, HttpError> = .init { [weak self] (observer, lifetime) in
                guard let self = self else {
                    observer.send(error: .zombieSelf)
                    return
                }
                guard let url = endpoint.url(relatedTo: self.server) else {
                    observer.send(error: .failedConstructUrl)
                    return
                }
                
                let httpRequest: URLRequest
                do {
                    httpRequest = try endpoint.request(url, httpTimeout: self.httpTimeout, accessToken: accessToken)
                } catch let error as HttpError {
                    observer.send(error: error)
                    return
                } catch {
                    observer.send(error: .httpFailure(error: error))
                    return
                }
                
                let codes = VoidResponse.successCodes
                let dataRequest: DataRequest = AF.request(httpRequest)
                dataRequest
                    .validate(statusCode: codes)
                    .response { (defaultResponse) in
                        if let error = defaultResponse.error {
                            let localError = HttpError.httpFailure(error: error)
                            observer.send(error: localError)
                        } else {
                            let value: Void = ()
                            observer.send(value: value)
                            observer.sendCompleted()
                        }
                }
                
                lifetime.observeEnded({
                    dataRequest.cancel()
                })
            }
            return producer
        }
    }
}
