//
//  ClosureVoidWrappers.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 2/10/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

#if canImport(Combine)
import Combine
#endif

extension HttpKit {
    // gryphon ignore
    public class ClosureVoidWrapper<Server: ServerDescription>: Hashable {
        public var closure: (Result<Void, HttpKit.HttpError>) -> Void
        /// Don't need to use endpoint here, but it is needed to create unique hash value for the closure
        let endpoint: VoidEndpoint<Server>
        
        public init(_ closure: @escaping (Result<Void, HttpKit.HttpError>) -> Void,
                    _ endpoint: VoidEndpoint<Server>) {
            self.closure = closure
            self.endpoint = endpoint
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine("closure")
            hasher.combine(endpoint)
            withUnsafePointer(to: &closure) {
                let strAddrs = "\($0)"
                hasher.combine(strAddrs)
            }
        }
        
        public static func == (lhs: ClosureVoidWrapper<Server>, rhs: ClosureVoidWrapper<Server>) -> Bool {
            return lhs.endpoint == rhs.endpoint
        }
    }
}

extension HttpKit {
    // gryphon ignore
    public class CombinePromiseVoidWrapper<Server: ServerDescription>: Hashable {
        public var promise: Future<Void, HttpKit.HttpError>.Promise
        /// Don't need to use endpoint here, but it is needed to create unique hash value for the closure
        let endpoint: VoidEndpoint<Server>
        
        public init(_ promise: @escaping Future<Void, HttpKit.HttpError>.Promise,
                    _ endpoint: VoidEndpoint<Server>) {
            self.promise = promise
            self.endpoint = endpoint
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine("combine.promise")
            hasher.combine(endpoint)
            withUnsafePointer(to: &promise) {
                let strAddrs = "\($0)"
                hasher.combine(strAddrs)
            }
        }
        
        public static func == (lhs: CombinePromiseVoidWrapper<Server>,
                               rhs: CombinePromiseVoidWrapper<Server>) -> Bool {
            return lhs.endpoint == rhs.endpoint
        }
    }
}
