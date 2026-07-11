//
//  CombineExtensions.swift
//  CottonRestKit
//
//  Created by Andrei Ermoshin on 4/29/20.
//  Copyright © 2020 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation
#if canImport(Combine)
import Combine
#endif

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Combine.Future {
    /// Create a failure Combine future
    ///
    /// - Parameter error: An error to use for the Future
    static func failure(_ error: Failure) -> Future<Output, Failure> {
        let future: Future<Output, Failure> = .init { (promise) in
            promise(.failure(error))
        }
        return future
    }

    /// Create a success Combine future
    ///
    /// - Parameter value: A value to use for the Future
    static func success(_ value: Output) -> Future<Output, Failure> {
        let future: Future<Output, Failure> = .init { (promise) in
            promise(.success(value))
        }
        return future
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Combine.Deferred {
    /// Create a deferred publisher using another one
    public init(_ instantePublisher: DeferredPublisher) {
        self.init { () -> DeferredPublisher in
            return instantePublisher
        }
    }
}
