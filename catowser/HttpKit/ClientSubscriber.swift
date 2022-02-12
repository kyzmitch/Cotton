//
//  HttpResponsesPool.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 2/10/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation

extension HttpKit {
    /// I already don't like this idea and this class, it will be for every endpoint
    /// This is only because I want to support generics for endpoints
    /// The main issue which needs to be solved by this class is to not add ResponseType or Endpoint type to the HttpClient
    /// HttpClient should only be dependent on ServerDescription
    /// And it all started because I wanted to remove Alamofire from direct dependency in HttpClient
    /// It lead to the issue that clsoures or Rx observers should be stored somewhere outside async HttpClient methods
    /// Because they can't be deallocated during async requests
    /// It must be a reference type because we will pass it to Http.Client methods
    public class ClientSubscriber<T, S, R: RxInterface> where R.RO.R == T, R.S == S {
        /// Can't use protocol type because it has associated type, should be associated with Endpoint response type
        var handlers = Set<ResponseHandlingApi<T, S, R>>()
        
        public init() {}
        
        public func insert(_ handler: ResponseHandlingApi<T, S, R>) {
            handlers.insert(handler)
        }
        
        public func remove(_ handler: ResponseHandlingApi<T, S, R>) {
            handlers.remove(handler)
        }
    }
}
