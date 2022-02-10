//
//  ClosureVoidWrappers.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 2/10/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import ReactiveSwift
#if canImport(Combine)
import Combine
#endif

extension HttpKit {
    public class ClosureVoidWrapper<S: ServerDescription>: Hashable {
        public let closure: (Result<Void, HttpKit.HttpError>) -> Void
        /// Don't need to use endpoint here, but it is needed to create unique hash value for the closure
        let endpoint: VoidEndpoint<S>
        
        public init(_ closure: @escaping (Result<Void, HttpKit.HttpError>) -> Void,
                    _ endpoint: VoidEndpoint<S>) {
            self.closure = closure
            self.endpoint = endpoint
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine("closure")
            hasher.combine(endpoint)
        }
        
        public static func == (lhs: ClosureVoidWrapper<S>, rhs: ClosureVoidWrapper<S>) -> Bool {
            return lhs.endpoint == rhs.endpoint
        }
    }
}

extension HttpKit {
    public class RxObserverVoidWrapper<S: ServerDescription>: Hashable {
        public let observer: Signal<Void, HttpKit.HttpError>.Observer
        public let lifetime: Lifetime
        /// Don't need to use endpoint here, but it is needed to create unique hash value for the closure
        let endpoint: VoidEndpoint<S>
        
        public init(_ observer: Signal<Void, HttpKit.HttpError>.Observer,
                    _ lifetime: Lifetime,
                    _ endpoint: VoidEndpoint<S>) {
            self.observer = observer
            self.lifetime = lifetime
            self.endpoint = endpoint
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine("rx.observer")
            hasher.combine(endpoint)
        }
        
        public static func == (lhs: RxObserverVoidWrapper<S>, rhs: RxObserverVoidWrapper<S>) -> Bool {
            return lhs.endpoint == rhs.endpoint
        }
    }
}

extension HttpKit {
    public class CombinePromiseVoidWrapper<S: ServerDescription>: Hashable {
        public let promise: Future<Void, HttpKit.HttpError>.Promise
        /// Don't need to use endpoint here, but it is needed to create unique hash value for the closure
        let endpoint: VoidEndpoint<S>
        
        public init(_ promise: @escaping Future<Void, HttpKit.HttpError>.Promise,
                    _ endpoint: VoidEndpoint<S>) {
            self.promise = promise
            self.endpoint = endpoint
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine("combine.promise")
            hasher.combine(endpoint)
        }
        
        public static func == (lhs: CombinePromiseVoidWrapper<S>, rhs: CombinePromiseVoidWrapper<S>) -> Bool {
            return lhs.endpoint == rhs.endpoint
        }
    }
}
