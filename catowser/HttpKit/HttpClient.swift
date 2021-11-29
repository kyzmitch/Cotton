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
        
        private func makeRequest<T: ResponseType>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                  withAccessToken accessToken: String?,
                                                  responseType: T.Type,
                                                  completionHandler: @escaping (Result<T, HttpKit.HttpError>) -> Void) {
            guard let url = endpoint.url(relatedTo: self.server) else {
                let result: Result<T, HttpKit.HttpError> = .failure(.failedConstructUrl)
                completionHandler(result)
                return
            }
            
            let httpRequest: URLRequest
            do {
                httpRequest = try endpoint.request(url, httpTimeout: self.httpTimeout, accessToken: accessToken)
            } catch let error as HttpKit.HttpError {
                let result: Result<T, HttpKit.HttpError> = .failure(error)
                completionHandler(result)
                return
            } catch {
                let result: Result<T, HttpKit.HttpError> = .failure(.httpFailure(error: error))
                completionHandler(result)
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
                    let result: Result<T, HttpKit.HttpError>
                    switch response.result {
                    case .success(let value):
                        result = .success(value)
                    case .failure(let error):
                        result = .failure(.httpFailure(error: error))
                    }
                    completionHandler(result)
                })
        }
        
        public func makePublicRequest<T: ResponseType>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                       responseType: T.Type,
                                                       completionHandler: @escaping (Result<T, HttpKit.HttpError>) -> Void) {
            makeRequest(for: endpoint,
                           withAccessToken: nil,
                           responseType: responseType,
                           completionHandler: completionHandler)
        }
        
        public func makeAuthorizedRequest<T: ResponseType>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                           withAccessToken accessToken: String,
                                                           responseType: T.Type,
                                                           completionHandler: @escaping (Result<T, HttpKit.HttpError>) -> Void) {
            makeRequest(for: endpoint,
                           withAccessToken: accessToken,
                           responseType: responseType,
                           completionHandler: completionHandler)
        }
        
        func makeVoidRequest(for endpoint: HttpKit.VoidEndpoint<Server>,
                             withAccessToken accessToken: String?,
                             completionHandler: @escaping (Result<Void, HttpKit.HttpError>) -> Void) {
            guard let url = endpoint.url(relatedTo: self.server) else {
                let result: Result<Void, HttpKit.HttpError> = .failure(.failedConstructUrl)
                completionHandler(result)
                return
            }
            
            let httpRequest: URLRequest
            do {
                httpRequest = try endpoint.request(url, httpTimeout: self.httpTimeout, accessToken: accessToken)
            } catch let error as HttpKit.HttpError {
                let result: Result<Void, HttpKit.HttpError> = .failure(error)
                completionHandler(result)
                return
            } catch {
                let result: Result<Void, HttpKit.HttpError> = .failure(.httpFailure(error: error))
                completionHandler(result)
                return
            }
            
            let codes = HttpKit.VoidResponse.successCodes
            let dataRequest: DataRequest = AF.request(httpRequest)
            dataRequest
                .validate(statusCode: codes)
                .response { (defaultResponse) in
                    let result: Result<Void, HttpKit.HttpError>
                    if let error = defaultResponse.error {
                        let localError = HttpKit.HttpError.httpFailure(error: error)
                        result = .failure(localError)
                    } else {
                        let value: Void = ()
                        result = .success(value)
                    }
                    completionHandler(result)
            }
        }
    }
}
