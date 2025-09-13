//
//  ClosureVoidWrappers.swift
//  CottonRestKit
//
//  Created by Andrei Ermoshin on 2/10/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

#if canImport(Combine)
import Combine
#endif
import CottonBase

/// Closure void wrapper
public class ClosureVoidWrapper<Server: ServerDescription>: Hashable {
    /// Closure
    public var closure: (Result<Void, HttpError>) -> Void
    /// Don't need to use endpoint here, but it is needed to create unique hash value for the closure
    let endpoint: Endpoint<Server>

    /// Init
    public init(
        _ closure: @escaping (Result<Void, HttpError>) -> Void,
        _ endpoint: Endpoint<Server>
    ) {
        self.closure = closure
        self.endpoint = endpoint
    }

    /// Save hash into hasher
    public func hash(into hasher: inout Hasher) {
        hasher.combine("closure")
        hasher.combine(endpoint)
        withUnsafePointer(to: &closure) {
            let strAddrs = "\($0)"
            hasher.combine(strAddrs)
        }
    }

    /// Equality operator
    public static func == (
        lhs: ClosureVoidWrapper<Server>,
        rhs: ClosureVoidWrapper<Server>
    ) -> Bool {
        lhs.endpoint == rhs.endpoint
    }
}

/// Combine promise void wrapper
public class CombinePromiseVoidWrapper<Server: ServerDescription>: Hashable {
    /// Promise
    public var promise: Future<Void, HttpError>.Promise
    /// Don't need to use endpoint here, but it is needed to create unique hash value for the closure
    let endpoint: Endpoint<Server>

    /// Init
    public init(
        _ promise: @escaping Future<Void, HttpError>.Promise,
        _ endpoint: Endpoint<Server>
    ) {
        self.promise = promise
        self.endpoint = endpoint
    }

    /// Hash into the hasher
    public func hash(into hasher: inout Hasher) {
        hasher.combine("combine.promise")
        hasher.combine(endpoint)
        withUnsafePointer(to: &promise) {
            let strAddrs = "\($0)"
            hasher.combine(strAddrs)
        }
    }

    /// Equality
    public static func == (
        lhs: CombinePromiseVoidWrapper<Server>,
        rhs: CombinePromiseVoidWrapper<Server>
    ) -> Bool {
        lhs.endpoint == rhs.endpoint
    }
}
