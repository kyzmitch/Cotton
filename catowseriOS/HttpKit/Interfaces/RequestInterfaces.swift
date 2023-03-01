//
//  RequestInterfaces.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 4/17/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import CottonCoreBaseKit
import AutoMockable

public protocol URLRequestCreatable: AutoMockable {
    func convertToURLRequest() throws -> URLRequest
}

extension URLRequest: URLRequestCreatable {
    public func convertToURLRequest() throws -> URLRequest {
        return self
    }
}

/// Interface for some JSON encoder (e.g. Alamofire implementation) to hide it and
/// not use it directly and be able to mock it for unit testing
public protocol JSONRequestEncodable: AutoMockable {
    func encodeRequest(_ urlRequest: URLRequestCreatable, with parameters: [String: Any]?) throws -> URLRequest
}

/// Non-nominal types cannot be extended.
/// Void is an empty tuple, and because tuples are non-nominal types,
/// you can’t add methods or properties or conformance to protocols.
/// https://nshipster.com/void/
public struct VoidResponse: ResponseType {
    public static var successCodes: [Int] {
        return [200, 201]
    }
}
