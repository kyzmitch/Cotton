//
//  HttpResponsesPool.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 2/10/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation

/// Should be used for async interfaces which use RX library
public typealias RxSubscriber<R, S, RX: RxInterface> = HttpKit.ClientRxSubscriber<R, S, RX>
    where RX.S == S, RX.RO.Response == R
/// Can be used for async interfaces which do not need RX stuff, like Combine or simple Closures
public typealias Subscriber<R: ResponseType, S: ServerDescription> = HttpKit.ClientSubscriber<R, S>

extension HttpKit {
    /// I already don't like this idea and this class, it will be for every endpoint
    /// This is only because I want to support generics for endpoints
    /// The main issue which needs to be solved by this class is to not add ResponseType
    /// or Endpoint type to the HttpClient
    /// HttpClient should only be dependent on ServerDescription
    /// And it all started because I wanted to remove Alamofire from direct dependency in HttpClient
    /// It lead to the issue that clsoures or Rx observers should be stored somewhere outside async HttpClient methods
    /// Because they can't be deallocated during async requests
    /// It must be a reference type because we will pass it to Http.Client methods
    public class ClientRxSubscriber<R, S, RX: RxInterface> where RX.RO.Response == R, RX.S == S {
        /// Can't use protocol type because it has associated type, should be associated with Endpoint response type
        var handlers = Set<ResponseHandlingApi<R, S, RX>>()
        
        public init() {}
        
        public func insert(_ handler: ResponseHandlingApi<R, S, RX>) {
            handlers.insert(handler)
        }
        
        public func remove(_ handler: ResponseHandlingApi<R, S, RX>) {
            handlers.remove(handler)
        }
    }
}

extension HttpKit {
    public typealias RxFreeInterface<R: ResponseType, S: ServerDescription> = DummyRxType<R, S, DummyRxObserver<R>>
    public class ClientSubscriber<R: ResponseType,
                                  S: ServerDescription>: ClientRxSubscriber<R, S, RxFreeInterface<R, S>> {
        
    }
}
