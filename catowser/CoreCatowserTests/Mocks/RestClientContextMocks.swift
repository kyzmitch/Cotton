//
//  RestClientContextMocks.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 10/4/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CoreCatowser

final class MockedDNSContext: RestClientContext {
    public typealias Response = MockedDNSResponse
    public typealias Server = MockedGoodDnsServer
    public typealias ReachabilityAdapter = MockedReachabilityAdaptee<Server>
    public typealias Encoder = MockedGoodJSONEncoding
    public typealias Client = MockedRestInterface<Server, ReachabilityAdapter, Encoder>
    
    public let client: Client
    public let rxSubscriber: HttpKitRxSubscriber
    public let subscriber: HttpKitSubscriber
    
    public init(_ client: Client,
                _ rxSubscriber: HttpKitRxSubscriber,
                _ subscriber: HttpKitSubscriber) {
        self.client = client
        self.rxSubscriber = rxSubscriber
        self.subscriber = subscriber
    }
}
