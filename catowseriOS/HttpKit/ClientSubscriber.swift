//
//  HttpResponsesPool.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 2/10/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import CottonBase

/// Should be used for async interfaces which use RX library
public typealias RxSubscriber<R, S, RX: RxInterface> = ClientRxSubscriber<R, S, RX>
    where RX.Server == S, RX.Observer.Response == R
public typealias RxVoidSubscriber<S, RX: RxVoidInterface> = ClientRxVoidSubscriber<S, RX>
    where RX.Server == S
/// Can be used for async interfaces which do not need RX stuff, like Combine or simple Closures
public typealias Subscriber<R: ResponseType, S: ServerDescription> = ClientSubscriber<R, S>

/// I already don't like this idea and this class, it will be for every endpoint
/// This is only because I want to support generics for endpoints
/// The main issue which needs to be solved by this class is to not add ResponseType
/// or Endpoint type to the HttpClient
/// HttpClient should only be dependent on ServerDescription
/// And it all started because I wanted to remove Alamofire from direct dependency in HttpClient
/// It lead to the issue that clsoures or Rx observers should be stored somewhere outside async HttpClient methods
/// Because they can't be deallocated during async requests
/// It must be a reference type because we will pass it to RestClient methods
// gryphon ignore
public class ClientRxSubscriber<R, S, RX: RxInterface> where RX.Observer.Response == R, RX.Server == S {
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

// gryphon ignore
public class ClientRxVoidSubscriber<S, RX: RxVoidInterface> where RX.Server == S {
    /// Can't use protocol type because it has associated type, should be associated with Endpoint response type
    var handlers = Set<ResponseVoidHandlingApi<S, RX>>()
    
    public init() {}
    
    public func insert(_ handler: ResponseVoidHandlingApi<S, RX>) {
        handlers.insert(handler)
    }
    
    public func remove(_ handler: ResponseVoidHandlingApi<S, RX>) {
        handlers.remove(handler)
    }
}

// gryphon ignore
public typealias RxFreeInterface<R: ResponseType, S: ServerDescription> = DummyRxType<R, S, DummyRxObserver<R>>
// gryphon ignore
public typealias ClientSubscriber<R: ResponseType,
                                  S: ServerDescription> = ClientRxSubscriber<R, S, RxFreeInterface<R, S>>
