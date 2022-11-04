//
//  RestClient.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/11/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
#if canImport(Combine)
import Combine
#endif
import CoreHttpKit

fileprivate extension String {
    static let threadName = "Client"
}

public typealias HttpTypedResult<T> = Result<T, HttpError>
public typealias TypedResponseClosure<T> = (HttpTypedResult<T>) -> Void

public class RestClient<S: ServerDescription,
                        R: NetworkReachabilityAdapter,
                        E: JSONRequestEncodable>: RestInterface where R.Server == S {
    public typealias Server = S
    public typealias Reachability = R
    public typealias Encoder = E
    
    public let server: Server
    
    public let jsonEncoder: Encoder
    
    private let connectivityManager: R?
    
    let sessionTaskHandler: HttpClientSessionTaskDelegate?
    
    let urlSessionHandler: HttpClientUrlSessionDelegate?
    
    private let urlSessionQueue: DispatchQueue = .init(label: "com.ae.HttpKit." + .threadName)
    
    /// Used only for async/await implementation when Alamofire can't be used naturally
    let urlSession: URLSession
    
    let httpTimeout: TimeInterval
    
    private lazy var hostListener: NetworkReachabilityAdapter.Listener = { [weak self] status in
        guard let self = self else {
            return
        }
        // TODO: need some interface for reachability but without RX (MutableProperty)
    }
    
    public required init(server: S,
                         jsonEncoder: E,
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
}