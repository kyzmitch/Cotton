//
//  AlamofireReachabilityAdaptee.swift
//  BrowserNetworking
//
//  Created by Andrei Ermoshin on 2/11/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import HttpKit
import Alamofire

public final class AlamofireReachabilityAdaptee<S: ServerDescription>: NetworkReachabilityAdapter {
    let connectivityManager: NetworkReachabilityManager
    public typealias S = S
    
    public init?(server: S) {
        if let manager = NetworkReachabilityManager(host: server.hostString) {
            connectivityManager = manager
        } else if let manager = NetworkReachabilityManager() {
            connectivityManager = manager
        } else {
            assertionFailure("No connectivity manager for: \(server.hostString)")
            return nil
        }
        return nil
    }
    
    public func startListening(onQueue queue: DispatchQueue, onUpdatePerforming listener: @escaping Listener) -> Bool {
        let closure = { (status: Alamofire.NetworkReachabilityManager.NetworkReachabilityStatus) -> Void in
            listener(status.httpKitValue)
        }
        return connectivityManager.startListening(onQueue: queue, onUpdatePerforming: closure)
    }
}

extension Alamofire.NetworkReachabilityManager.NetworkReachabilityStatus.ConnectionType {
    var httpKitValue: HttpKit.NetworkReachabilityStatus.ConnectionType {
        switch self {
        case .ethernetOrWiFi:
            return .ethernetOrWiFi
        case .cellular:
            return .cellular
        }
    }
}

extension Alamofire.NetworkReachabilityManager.NetworkReachabilityStatus {
    var httpKitValue: HttpKit.NetworkReachabilityStatus {
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
