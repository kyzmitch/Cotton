//
//  AlamofireReachabilityAdaptee.swift
//  CottonNetworking
//
//  Created by Andrei Ermoshin on 2/11/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import CottonRestKit
@preconcurrency import Alamofire
import CottonBase

/// Alamofire implementation for reachability adapter
public final class AlamofireReachabilityAdaptee<S: ServerDescription>: NetworkReachabilityAdapter {
    let connectivityManager: NetworkReachabilityManager
    /// Server type
    public typealias Server = S
    /// Init
    public init?(server: Server) {
        if let manager = NetworkReachabilityManager(host: server.host.rawString) {
            connectivityManager = manager
        } else if let manager = NetworkReachabilityManager() {
            connectivityManager = manager
        } else {
            assertionFailure("No connectivity manager for: \(server.host.rawString)")
            return nil
        }
    }

    /// Start observing
    public func startListening(
        onQueue queue: DispatchQueue,
        onUpdatePerforming listener: @escaping Listener
    ) -> Bool {
        let closure = { (status: Alamofire.NetworkReachabilityManager.NetworkReachabilityStatus) -> Void in
            listener(status.httpKitValue)
        }
        return connectivityManager.startListening(onQueue: queue, onUpdatePerforming: closure)
    }

    /// Stop observing
    public func stopListening() {
        connectivityManager.stopListening()
    }
}

extension Alamofire.NetworkReachabilityManager.NetworkReachabilityStatus.ConnectionType {
    var httpKitValue: NetworkReachabilityStatus.ConnectionType {
        switch self {
        case .ethernetOrWiFi:
            return .ethernetOrWiFi
        case .cellular:
            return .cellular
        }
    }
}

extension Alamofire.NetworkReachabilityManager.NetworkReachabilityStatus {
    var httpKitValue: NetworkReachabilityStatus {
        switch self {
        case .unknown:
            return .unknown
        case .notReachable:
            return .notReachable
        case .reachable(let contentType):
            return .reachable(contentType.httpKitValue)
        }
    }
}
