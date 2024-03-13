//
//  CombineExtensions.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 4/29/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
#if canImport(Combine)
import Combine
#endif

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Combine.Future {
    public static func failure(_ error: Failure) -> Future<Output, Failure> {
        let future: Future<Output, Failure> = .init { (promise) in
            promise(.failure(error))
        }
        return future
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension Combine.Deferred {
    public init(_ instantePublisher: DeferredPublisher) {
        self.init { () -> DeferredPublisher in
            return instantePublisher
        }
    }
}
