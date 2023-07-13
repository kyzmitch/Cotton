//
//  JSONEncodableMocks.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 10/4/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import HttpKit

struct MockedGoodJSONEncoding: JSONRequestEncodable {
    func encodeRequest(_ urlRequest: URLRequestCreatable, with parameters: [String: Any]?) throws -> URLRequest {
        return try urlRequest.convertToURLRequest()
    }
}
