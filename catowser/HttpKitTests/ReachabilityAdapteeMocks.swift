//
//  ReachabilityAdapteeMocks.swift
//  HttpKitTests
//
//  Created by Andrei Ermoshin on 2/12/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import HttpKit

final class MockedReachabilityAdaptee<S: ServerDescription>: NetworkReachabilityAdapter {
    public typealias S = S
    
    public init?(server: S) {}
    
    public func startListening(onQueue queue: DispatchQueue, onUpdatePerforming listener: @escaping Listener) -> Bool {
        listener(.reachable(.ethernetOrWiFi))
        return true
    }
}
