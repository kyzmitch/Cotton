//
//  HTTPRequestInfo+SwiftHttpExtension.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 7/11/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import CottonCoreBaseKit
import HTTPTypes

extension CottonCoreBaseKit.HTTPMethod {
    var swiftValue: HTTPRequest.Method {
        switch self {
        case .get:
            return .get
        case .post:
            return .post
        default:
            assertionFailure("Unknown http method case")
            return .get
        }
    }
}

extension HTTPRequestInfo {
    var swiftRequest: HTTPRequest {
        // TODO: finish conversion
        HTTPRequest(method: method.swiftValue, scheme: "https", authority: "www.example.com", path: "/")
    }
}
