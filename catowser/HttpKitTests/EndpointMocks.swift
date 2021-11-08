//
//  EndpointMocks.swift
//  HttpKitTests
//
//  Created by Andrei Ermoshin on 11/8/21.
//  Copyright © 2021 andreiermoshin. All rights reserved.
//

import HttpKit

struct MockedGoodEndpointResponse: ResponseType {
    static var successCodes: [Int] {
        return [200]
    }
}

struct MockedGoodServer: ServerDescription {
    var hostString: String {
        return "\(prefix).\(domain)"
    }
    
    let domain: String = "example.com"
    
    let prefix = "www"
    
    init() {}
}

typealias MockedGoodEndpoint = HttpKit.Endpoint<MockedGoodEndpointResponse, MockedGoodServer>
