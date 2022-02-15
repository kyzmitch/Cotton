//
//  ClosureWrappers.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 2/10/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

#if canImport(Combine)
import Combine
#endif

extension HttpKit {
    public class ClosureWrapper<Response: ResponseType, Server: ServerDescription>: Hashable {
        public let closure: (Result<Response, HttpKit.HttpError>) -> Void
        /// Don't need to use endpoint here, but it is needed to create unique hash value for the closure
        let endpoint: Endpoint<Response, Server>
        let responseType: Response.Type
        
        public init(_ closure: @escaping (Result<Response, HttpKit.HttpError>) -> Void,
                    _ endpoint: Endpoint<Response, Server>) {
            self.closure = closure
            self.endpoint = endpoint
            responseType = Response.self
        }
        
        public func hash(into hasher: inout Hasher) {
            let typeString = String(describing: responseType)
            hasher.combine(typeString)
            hasher.combine("closure")
            hasher.combine(responseType.successCodes)
            hasher.combine(endpoint)
        }
        
        public static func == (lhs: ClosureWrapper<Response, Server>, rhs: ClosureWrapper<Response, Server>) -> Bool {
            return lhs.responseType == rhs.responseType && lhs.endpoint == rhs.endpoint
        }
    }
}

extension HttpKit {
    public class CombinePromiseWrapper<Response: ResponseType, Server: ServerDescription>: Hashable {
        public let promise: Future<Response, HttpKit.HttpError>.Promise
        /// Don't need to use endpoint here, but it is needed to create unique hash value for the closure
        let endpoint: Endpoint<Response, Server>
        let responseType: Response.Type
        
        public init(_ promise: @escaping Future<Response, HttpKit.HttpError>.Promise,
                    _ endpoint: Endpoint<Response, Server>) {
            self.promise = promise
            self.endpoint = endpoint
            responseType = Response.self
        }
        
        public func hash(into hasher: inout Hasher) {
            let typeString = String(describing: responseType)
            hasher.combine(typeString)
            hasher.combine("combine.promise")
            hasher.combine(responseType.successCodes)
            hasher.combine(endpoint)
        }
        
        public static func == (lhs: CombinePromiseWrapper<Response, Server>,
                               rhs: CombinePromiseWrapper<Response, Server>) -> Bool {
            return lhs.responseType == rhs.responseType && lhs.endpoint == rhs.endpoint
        }
    }
}
