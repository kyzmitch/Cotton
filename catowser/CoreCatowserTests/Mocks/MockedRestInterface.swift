//
//  MockedRestInterface.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 10/30/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import HttpKit
import CoreHttpKit

final class MockedRestInterface<S: ServerDescription,
                                R: NetworkReachabilityAdapter,
                                E: JSONRequestEncodable>: RestInterface where R.Server == S {
    typealias Server = S
    typealias Reachability = R
    typealias Encoder = E
    
    let server: Server
    let jsonEncoder: Encoder
    
    init(server: S, jsonEncoder: E, reachability: R, httpTimeout: TimeInterval = 10) {
        self.server = server
        self.jsonEncoder = jsonEncoder
    }
}
