//
//  ClosureWrappers.swift
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
    public class ClosureWrapper<TYPE: ResponseType, S: ServerDescription>: Hashable {
        public let closure: (Result<TYPE, HttpKit.HttpError>) -> Void
        /// Don't need to use endpoint here, but it is needed to create unique hash value for the closure
        let endpoint: Endpoint<TYPE, S>
        let responseType: TYPE.Type
        
        public init(_ closure: @escaping (Result<TYPE, HttpKit.HttpError>) -> Void,
                    _ endpoint: Endpoint<TYPE, S>) {
            self.closure = closure
            self.endpoint = endpoint
            responseType = TYPE.self
        }
        
        public func hash(into hasher: inout Hasher) {
            let typeString = String(describing: responseType)
            hasher.combine(typeString)
            hasher.combine("closure")
            hasher.combine(responseType.successCodes)
            hasher.combine(endpoint)
        }
        
        public static func == (lhs: ClosureWrapper<TYPE, S>, rhs: ClosureWrapper<TYPE, S>) -> Bool {
            return lhs.responseType == rhs.responseType && lhs.endpoint == rhs.endpoint
        }
    }
}

extension HttpKit {
    public class RxObserverWrapper<R: ResponseType, S: ServerDescription>: Hashable {
        public let observer: Signal<R, HttpKit.HttpError>.Observer
        public let lifetime: Lifetime
        /// Don't need to use endpoint here, but it is needed to create unique hash value for the closure
        let endpoint: Endpoint<R, S>
        let responseType: R.Type
        
        public init(_ observer: Signal<R, HttpKit.HttpError>.Observer,
                    _ lifetime: Lifetime,
                    _ endpoint: Endpoint<R, S>) {
            self.observer = observer
            self.lifetime = lifetime
            self.endpoint = endpoint
            responseType = R.self
        }
        
        public func hash(into hasher: inout Hasher) {
            let typeString = String(describing: responseType)
            hasher.combine(typeString)
            hasher.combine("rx.observer")
            hasher.combine(responseType.successCodes)
            hasher.combine(endpoint)
        }
        
        public static func == (lhs: RxObserverWrapper<R, S>, rhs: RxObserverWrapper<R, S>) -> Bool {
            return lhs.responseType == rhs.responseType && lhs.endpoint == rhs.endpoint
        }
    }
}

extension HttpKit {
    public class CombinePromiseWrapper<R: ResponseType, S: ServerDescription>: Hashable {
        public let promise: Future<R, HttpKit.HttpError>.Promise
        /// Don't need to use endpoint here, but it is needed to create unique hash value for the closure
        let endpoint: Endpoint<R, S>
        let responseType: R.Type
        
        public init(_ promise: @escaping Future<R, HttpKit.HttpError>.Promise,
                    _ endpoint: Endpoint<R, S>) {
            self.promise = promise
            self.endpoint = endpoint
            responseType = R.self
        }
        
        public func hash(into hasher: inout Hasher) {
            let typeString = String(describing: responseType)
            hasher.combine(typeString)
            hasher.combine("combine.promise")
            hasher.combine(responseType.successCodes)
            hasher.combine(endpoint)
        }
        
        public static func == (lhs: CombinePromiseWrapper<R, S>, rhs: CombinePromiseWrapper<R, S>) -> Bool {
            return lhs.responseType == rhs.responseType && lhs.endpoint == rhs.endpoint
        }
    }
}
