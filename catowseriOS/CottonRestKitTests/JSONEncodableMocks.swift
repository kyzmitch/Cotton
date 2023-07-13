//
//  JSONEncodableMocks.swift
//  HttpKitTests
//
//  Created by Andrei Ermoshin on 2/8/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CottonRestKit

struct MockedGoodJSONEncoding: JSONRequestEncodable {
    func encodeRequest(_ urlRequest: URLRequestCreatable, with parameters: [String: Any]?) throws -> URLRequest {
        return try urlRequest.convertToURLRequest()
    }
}
