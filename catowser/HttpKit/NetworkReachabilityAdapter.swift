//
//  NetworkReachabilityAdapter.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 2/11/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CottonCoreBaseKit
import AutoMockable

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
    
    public var isReachable: Bool {
        switch self {
        case .unknown:
            return false
        case .notReachable:
            return false
        case .reachable:
            return true
        }
    }
}

// swiftlint:disable comment_spacing
//sourcery: associatedtype = "Server: ServerDescription"
public protocol NetworkReachabilityAdapter: AnyObject, AutoMockable {
    // swiftlint:enable comment_spacing
    associatedtype Server: ServerDescription
    typealias Listener = (NetworkReachabilityStatus) -> Void
    init?(server: Server)
    @discardableResult
    func startListening(onQueue queue: DispatchQueue,
                        onUpdatePerforming listener: @escaping Listener) -> Bool
    func stopListening()
}
