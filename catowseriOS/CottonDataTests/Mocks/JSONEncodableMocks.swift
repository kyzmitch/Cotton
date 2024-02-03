//
//  JSONEncodableMocks.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 10/4/22.
//  Copyright © 2022 Cotton (former Catowser). All rights reserved.
//

import CottonRestKit

struct MockedGoodJSONEncoding: JSONRequestEncodable {
    func encodeRequest(_ urlRequest: URLRequestCreatable, with parameters: [String: Any]?) throws -> URLRequest {
        return try urlRequest.convertToURLRequest()
    }
}
