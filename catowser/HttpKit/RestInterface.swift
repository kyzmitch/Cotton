//
//  RestInterface.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/27/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import CoreHttpKit
import AutoMockable

extension ServerDescription: AutoMockable {}

// swiftlint:disable comment_spacing
//sourcery: associatedtype = "Server: ServerDescription"
//sourcery: associatedtype = "Reachability: NetworkReachabilityAdapter"
//sourcery: associatedtype = "Encoder: JSONRequestEncodable"
//sourcery: typealias = "Server = Server"
//sourcery: typealias = "Reachability = Reachability"
//sourcery: typealias = "Encoder = Encoder"
public protocol RestInterface: AnyObject, AutoMockable {
    // swiftlint:enable comment_spacing
    associatedtype Server: ServerDescription
    associatedtype Reachability: NetworkReachabilityAdapter where Reachability.Server == Server
    associatedtype Encoder: JSONRequestEncodable
    
    init(server: Server, jsonEncoder: Encoder, reachability: Reachability, httpTimeout: TimeInterval)
    
    var server: Server { get }
    var jsonEncoder: Encoder { get }
}
