//
//  ReachabilityAdapteeMocks.swift
//  HttpKitTests
//
//  Created by Andrei Ermoshin on 2/12/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import HttpKit
import CottonCoreBaseKit

final class MockedReachabilityAdaptee<S: ServerDescription>: NetworkReachabilityAdapter {
    public typealias Server = S
    
    public init?(server: Server) {}
    
    public func startListening(onQueue queue: DispatchQueue, onUpdatePerforming listener: @escaping Listener) -> Bool {
        listener(.reachable(.ethernetOrWiFi))
        return true
    }
    
    public func stopListening() {
    }
}