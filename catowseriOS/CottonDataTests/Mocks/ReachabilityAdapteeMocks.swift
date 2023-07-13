//
//  ReachabilityAdapteeMocks.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 10/4/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CottonRestKit
import CottonBase

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
