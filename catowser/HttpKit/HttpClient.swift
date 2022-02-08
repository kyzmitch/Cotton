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
    public class Client<Server: ServerDescription> {
        let server: Server
        
        private let connectivityManager: NetworkReachabilityManager?
        
        let sessionTaskHandler: HttpClientSessionTaskDelegate?
        
        let urlSessionHandler: HttpClientUrlSessionDelegate?
        
        private let urlSessionQueue: DispatchQueue = .init(label: "com.ae.HttpKit." + .threadName)
        
        /// Used only for async/await implementation when Alamofire can't be used naturally
        let urlSession: URLSession
        
        let httpTimeout: TimeInterval
        
        let jsonEncoder: JSONRequestEncodable
        
        public typealias HostNetState = NetworkReachabilityManager.NetworkReachabilityStatus
        
        public let connectionStateStream: MutableProperty<HostNetState>
        
        private lazy var hostListener: Alamofire.NetworkReachabilityManager.Listener = { [weak self] status in
            guard let self = self else {
                return
            }
            self.connectionStateStream.value = status
        }
        
        public init(server: Server, jsonEncoder: JSONRequestEncodable, httpTimeout: TimeInterval = 60) {
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
        
        // MARK: - Clear functions without dependencies
        
        /// T: ResponseType
        public func makeCleanRequest<T, B: HTTPNetworkingBackend>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                                  withAccessToken accessToken: String?,
                                                                  networkingBackend: B) where B.TYPE == T {
            guard let url = endpoint.url(relatedTo: self.server) else {
                let result: HttpTypedResult<T> = .failure(.failedConstructUrl)
                networkingBackend.wrapperHandler()(result)
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
                networkingBackend.wrapperHandler()(result)
                return
            } catch {
                let result: HttpTypedResult<T> = .failure(.httpFailure(error: error))
                networkingBackend.wrapperHandler()(result)
                return
            }
            
            let codes = T.successCodes
            networkingBackend.performRequest(httpRequest, sucessCodes: codes)
        }
        
        public func makeCleanVoidRequest(for endpoint: HttpKit.VoidEndpoint<Server>,
                                         withAccessToken accessToken: String?,
                                         networkingBackend: HTTPNetworkingBackendVoid) {
            guard let url = endpoint.url(relatedTo: self.server) else {
                let result: Result<Void, HttpKit.HttpError> = .failure(.failedConstructUrl)
                networkingBackend.wrapperHandler(result)
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
                networkingBackend.wrapperHandler(result)
                return
            } catch {
                let result: Result<Void, HttpKit.HttpError> = .failure(.httpFailure(error: error))
                networkingBackend.wrapperHandler(result)
                return
            }
            
            let codes = HttpKit.VoidResponse.successCodes
            networkingBackend.performVoidRequest(httpRequest, sucessCodes: codes)
        }
    }
}
