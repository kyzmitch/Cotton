//
//  EndpointMocks.swift
//  HttpKitTests
//
//  Created by Andrei Ermoshin on 11/8/21.
//  Copyright © 2021 Cotton (former Catowser). All rights reserved.
//

import CottonRestKit
import CottonBase

struct MockedGoodEndpointResponse: ResponseType {
    static var successCodes: [Int] {
        return [200]
    }
}

class MockedGoodServer: ServerDescription {
    convenience init() {
        // swiftlint:disable:next force_try
        let host = try! Host(input: "www.example.com")
        self.init(host: host, scheme: .https)
    }
}

typealias MockedGoodEndpoint = Endpoint<MockedGoodServer>
