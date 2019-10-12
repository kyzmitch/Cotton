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
    public class Client {
        private let server: ServerDescription
        
        private let connectivityManager: NetworkReachabilityManager?
        
        private let httpTimeout: TimeInterval
        
        private lazy var hostListener: Alamofire.NetworkReachabilityManager.Listener = { [weak self] status in
            guard let self = self else {
                return
            }
            // TODO: set connectionStateStream.value
        }
        
        public init(server: ServerDescription, httpTimeout: TimeInterval = 60) {
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
        }
        
        
    }
}
