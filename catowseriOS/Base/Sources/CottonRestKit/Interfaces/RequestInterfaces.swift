//
//  RequestInterfaces.swift
//  CottonRestKit
//
//  Created by Andrei Ermoshin on 4/17/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation
import CottonBase
import AutoMockable

/// URL request create interface (replacement for Alamofire version?)
public protocol URLRequestCreatable: AutoMockable {
    /// Convert one interface to a System URL request
    func convertToURLRequest() throws -> URLRequest
}

extension URLRequest: URLRequestCreatable {
    /// Convert one interface to a System URL request
    public func convertToURLRequest() throws -> URLRequest {
        return self
    }
}

/// Interface for some JSON encoder (e.g. Alamofire implementation) to hide it and
/// not use it directly and be able to mock it for unit testing
public protocol JSONRequestEncodable: AutoMockable, Sendable {
    /// Encode request
    ///
    /// - Parameter urlRequest: URL request interface
    /// - Parameter parameters: A table of parameters
    /// - Returns system URL request
    func encodeRequest(
        _ urlRequest: URLRequestCreatable,
        with parameters: [String: Any]?
    ) throws -> URLRequest
}

/// Non-nominal types cannot be extended.
/// Void is an empty tuple, and because tuples are non-nominal types,
/// you can’t add methods or properties or conformance to protocols.
/// https://nshipster.com/void/
public struct VoidResponse: ResponseType {
    /// Success codes for Void response
    public static var successCodes: [Int] {
        return [200, 201]
    }
}
