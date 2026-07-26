//
//  JSONEncodableMocks.swift
//  HttpKitTests
//
//  Created by Andrei Ermoshin on 2/8/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import CottonRestKit
import Foundation

struct MockedGoodJSONEncoding: JSONRequestEncodable {
    func encodeRequest(_ urlRequest: URLRequestCreatable, with parameters: [String: Any]?) throws -> URLRequest {
        return try urlRequest.convertToURLRequest()
    }
}
