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

/// Combine Future type is only available from ios 13 https://stackoverflow.com/a/68754297
/// Can't mark specific enum case to be available for certain OS version
/// Deployment target was set to 13.0 from 12.1 from now
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public enum ResponseHandlingApi<TYPE: ResponseType> {
    case closure((Result<TYPE, HttpKit.HttpError>) -> Void)
    case rxObserver(Signal<TYPE, HttpKit.HttpError>.Observer, Lifetime)
    case waitsForRxObserver
    case combine(Future<TYPE, HttpKit.HttpError>.Promise)
    case asyncAwaitConcurrency
    
    public var wrapperHandler: ((Result<TYPE, HttpKit.HttpError>) -> Void) {
        let closure = { (result: Result<TYPE, HttpKit.HttpError>) in
            switch self {
            case .closure(let originalClosure):
                originalClosure(result)
            case .rxObserver(let observer, _):
                switch result {
                case .success(let value):
                    observer.send(value: value)
                case .failure(let error):
                    observer.send(error: error)
                }
            case .waitsForRxObserver:
                break
            case .combine(let promise):
                promise(result)
            case .asyncAwaitConcurrency:
                break
            }
        }
        return closure
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public enum ResponseVoidHandlingApi {
    case closure((Result<Void, HttpKit.HttpError>) -> Void)
    case rxObserver(Signal<Void, HttpKit.HttpError>.Observer, Lifetime)
    case waitsForRxObserver
    case combine(Future<Void, HttpKit.HttpError>.Promise)
    case asyncAwaitConcurrency
    
    public var wrapperHandler: ((Result<Void, HttpKit.HttpError>) -> Void) {
        let closure = { (result: Result<Void, HttpKit.HttpError>) in
            switch self {
            case .closure(let originalClosure):
                originalClosure(result)
            case .rxObserver(let observer, _):
                switch result {
                case .success():
                    let value: Void = ()
                    observer.send(value: value)
                case .failure(let error):
                    observer.send(error: error)
                }
            case .waitsForRxObserver:
                break
            case .combine(let promise):
                promise(result)
            case .asyncAwaitConcurrency:
                break
            }
        }
        return closure
    }
}

/// Interface for some HTTP networking library (e.g. Alamofire) to hide it and
/// not use it directly and be able to mock it for unit testing
public protocol HTTPNetworkingBackend: AnyObject {
    associatedtype TYPE: ResponseType
    init(_ handlerType: ResponseHandlingApi<TYPE>)
    
    func performRequest(_ request: URLRequest,
                        sucessCodes: [Int])
    /// Should be the main closure which should call basic closure and Rx stuff (observer, lifetime) and Async stuff
    var wrapperHandler: ((Result<TYPE, HttpKit.HttpError>) -> Void) { get }
    /// Should refer to simple closure api
    var handlerType: ResponseHandlingApi<TYPE> { get }
    
    /* mutating */ func transferToRxState(_ observer: Signal<TYPE, HttpKit.HttpError>.Observer, _ lifetime: Lifetime)
}

public protocol HTTPNetworkingBackendVoid: AnyObject {
    init(_ handlerType: ResponseVoidHandlingApi)
    func performVoidRequest(_ request: URLRequest,
                            sucessCodes: [Int])
    var wrapperHandler: ((Result<Void, HttpKit.HttpError>) -> Void) { get }
    var handlerType: ResponseVoidHandlingApi { get }
    
    /* mutating */ func transferToRxState(_ observer: Signal<Void, HttpKit.HttpError>.Observer, _ lifetime: Lifetime)
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
        func makeCleanRequest<T, B: HTTPNetworkingBackend>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                           withAccessToken accessToken: String?,
                                                           networkingBackend: B) where B.TYPE == T {
            guard let url = endpoint.url(relatedTo: self.server) else {
                let result: HttpTypedResult<T> = .failure(.failedConstructUrl)
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
                let result: HttpTypedResult<T> = .failure(error)
                networkingBackend.wrapperHandler(result)
                return
            } catch {
                let result: HttpTypedResult<T> = .failure(.httpFailure(error: error))
                networkingBackend.wrapperHandler(result)
                return
            }
            
            let codes = T.successCodes
            networkingBackend.performRequest(httpRequest, sucessCodes: codes)
        }
        
        func makeCleanVoidRequest(for endpoint: HttpKit.VoidEndpoint<Server>,
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
