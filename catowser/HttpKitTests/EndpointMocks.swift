//
//  EndpointMocks.swift
//  HttpKitTests
//
//  Created by Andrei Ermoshin on 11/8/21.
//  Copyright © 2021 andreiermoshin. All rights reserved.
//

import HttpKit
import CoreHttpKit

struct MockedGoodEndpointResponse: ResponseType {
    static var successCodes: [Int] {
        return [200]
    }
}

class MockedGoodServer: ServerDescription {
    override var hostString: String { "\(prefix).\(domain)" }
    
    override var domain: String { "example.com" }
    
    private let prefix = "www"
    
    override init() {}
}

class MockedBadNoHostServer: ServerDescription {
    override var hostString: String { "" }
    
    override var domain: String { "" }
    
    override init() {}
}

typealias MockedGoodEndpoint = Endpoint<MockedGoodServer>
typealias MockedBadNoHostEndpoint = Endpoint<MockedBadNoHostServer>
