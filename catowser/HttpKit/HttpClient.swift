//
//  HttpClient.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/11/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
#if canImport(Combine)
import Combine
#endif

/// Main namespace for Kit
public enum HttpKit {}

fileprivate extension String {
    static let threadName = "Client"
}

public typealias HttpTypedResult<T> = Result<T, HttpKit.HttpError>
public typealias TypedResponseClosure<T> = (HttpTypedResult<T>) -> Void

extension HttpKit {
    public class Client<Server, R: NetworkReachabilityAdapter> where R.Server == Server {
        let server: Server
        
        private let connectivityManager: R?
        
        let sessionTaskHandler: HttpClientSessionTaskDelegate?
        
        let urlSessionHandler: HttpClientUrlSessionDelegate?
        
        private let urlSessionQueue: DispatchQueue = .init(label: "com.ae.HttpKit." + .threadName)
        
        /// Used only for async/await implementation when Alamofire can't be used naturally
        let urlSession: URLSession
        
        let httpTimeout: TimeInterval
        
        let jsonEncoder: JSONRequestEncodable
        
        private lazy var hostListener: NetworkReachabilityAdapter.Listener = { [weak self] status in
            guard let self = self else {
                return
            }
            // TODO: need some interface for reachability but without RX (MutableProperty)
        }
        
        public init(server: Server,
                    jsonEncoder: JSONRequestEncodable,
                    reachability: R,
                    httpTimeout: TimeInterval = 60) {
            self.server = server
            self.httpTimeout = httpTimeout
            self.jsonEncoder = jsonEncoder
            let sessionConfiguration = URLSessionConfiguration.default
            urlSessionHandler = .init()
            let operationQueue: OperationQueue = .init()
            operationQueue.underlyingQueue = urlSessionQueue
            urlSession = URLSession(configuration: sessionConfiguration,
                                    delegate: urlSessionHandler,
                                    delegateQueue: operationQueue)
            sessionTaskHandler = .init()
            
            connectivityManager = reachability
            guard let cManager = connectivityManager else {
                return
            }
            guard cManager.startListening(onQueue: .main, onUpdatePerforming: hostListener) else {
                print("Connectivity listening failed to start")
                return
            }
        }
        
        // MARK: - Clear RX capable functions without dependencies
        
        public func makeRxRequest<T, B: HTTPRxAdapter>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                       withAccessToken accessToken: String?,
                                                       transport adapter: B) where B.Response == T, B.Server == Server {
            
            guard let url = endpoint.url(relatedTo: self.server) else {
                let result: HttpTypedResult<T> = .failure(.failedConstructUrl)
                adapter.wrapperHandler()(result)
                return
            }
            let httpRequest: URLRequest
            do {
                httpRequest = try endpoint.request(url,
                                                   httpTimeout: self.httpTimeout,
                                                   jsonEncoder: jsonEncoder,
                                                   accessToken: accessToken)
            } catch let error as HttpKit.HttpError {
                let result: HttpTypedResult<T> = .failure(error)
                adapter.wrapperHandler()(result)
                return
            } catch {
                let result: HttpTypedResult<T> = .failure(.httpFailure(error: error))
                adapter.wrapperHandler()(result)
                return
            }
            
            let codes = T.successCodes
            adapter.performRequest(httpRequest, sucessCodes: codes)
        }
        
        public func makeRxVoidRequest<B: HTTPRxVoidAdapter>(for endpoint: HttpKit.VoidEndpoint<Server>,
                                                            withAccessToken accessToken: String?,
                                                            transport adapter: B) where B.Server == Server {
            guard let url = endpoint.url(relatedTo: self.server) else {
                let result: Result<Void, HttpKit.HttpError> = .failure(.failedConstructUrl)
                adapter.wrapperHandler()(result)
                return
            }
            
            let httpRequest: URLRequest
            do {
                httpRequest = try endpoint.request(url,
                                                   httpTimeout: self.httpTimeout,
                                                   jsonEncoder: jsonEncoder,
                                                   accessToken: accessToken)
            } catch let error as HttpKit.HttpError {
                let result: Result<Void, HttpKit.HttpError> = .failure(error)
                adapter.wrapperHandler()(result)
                return
            } catch {
                let result: Result<Void, HttpKit.HttpError> = .failure(.httpFailure(error: error))
                adapter.wrapperHandler()(result)
                return
            }
            
            let codes = HttpKit.VoidResponse.successCodes
            adapter.performVoidRequest(httpRequest, sucessCodes: codes)
        }
        
        // MARK: - Clear functions without dependencies
        
        public func makeRequest<T, B: HTTPAdapter>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                   withAccessToken accessToken: String?,
                                                   transport adapter: B) where B.Response == T, B.Server == Server {
            guard let url = endpoint.url(relatedTo: self.server) else {
                let result: HttpTypedResult<T> = .failure(.failedConstructUrl)
                adapter.wrapperHandler()(result)
                return
            }
            let httpRequest: URLRequest
            do {
                httpRequest = try endpoint.request(url,
                                                   httpTimeout: self.httpTimeout,
                                                   jsonEncoder: jsonEncoder,
                                                   accessToken: accessToken)
            } catch let error as HttpKit.HttpError {
                let result: HttpTypedResult<T> = .failure(error)
                adapter.wrapperHandler()(result)
                return
            } catch {
                let result: HttpTypedResult<T> = .failure(.httpFailure(error: error))
                adapter.wrapperHandler()(result)
                return
            }
            
            let codes = T.successCodes
            adapter.performRequest(httpRequest, sucessCodes: codes)
        }
    }
}
