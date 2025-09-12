//
//  RestInterface.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/27/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation
import CottonBase
import AutoMockable

// Can't mock `ServerDescription` because need to call base init somehow

// swiftlint:disable comment_spacing
//sourcery: associatedtype = "S: ServerDescription"
//sourcery: associatedtype = "RA: NetworkReachabilityAdapter where RA.Server == S"
//sourcery: associatedtype = "E: JSONRequestEncodable"
//sourcery: typealias = "Server = S"
//sourcery: typealias = "Reachability = RA"
//sourcery: typealias = "Encoder = E"
public protocol RestInterface: AnyObject, AutoMockable {
    // swiftlint:enable comment_spacing
    associatedtype Server: ServerDescription
    associatedtype Reachability: NetworkReachabilityAdapter where Reachability.Server == Server
    associatedtype Encoder: JSONRequestEncodable

    init(server: Server, jsonEncoder: Encoder, reachability: Reachability, httpTimeout: TimeInterval)

    var server: Server { get }
    var jsonEncoder: Encoder { get }
}
