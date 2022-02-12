//
//  NetworkReachabilityAdapter.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 2/11/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation

extension HttpKit {
    public enum NetworkReachabilityStatus {
        /// It is unknown whether the network is reachable.
        case unknown
        /// The network is not reachable.
        case notReachable
        /// The network is reachable on the associated `ConnectionType`.
        case reachable(ConnectionType)

        /// Defines the various connection types detected by reachability flags.
        public enum ConnectionType {
            /// The connection type is either over Ethernet or WiFi.
            case ethernetOrWiFi
            /// The connection type is a cellular connection.
            case cellular
        }
    }
}

public protocol NetworkReachabilityAdapter: AnyObject {
    associatedtype S: ServerDescription
    typealias Listener = (HttpKit.NetworkReachabilityStatus) -> Void
    init?(server: S)
    @discardableResult
    func startListening(onQueue queue: DispatchQueue,
                        onUpdatePerforming listener: @escaping Listener) -> Bool
}