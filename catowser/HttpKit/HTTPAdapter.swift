//
//  HTTPAdapter.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 2/8/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

#if canImport(Combine)
import Combine
#endif

/// Interface for some HTTP networking library (e.g. Alamofire or URLSession) to hide it and
/// not use it directly and be able to mock it for unit testing.
/// Also, it allows to use completely different callback APIs (closure, Reactive observers, Combine promises, etc.
/// It seems it should be only implemented by classes (see AnyObject requirement),
/// because network library API probably uses closures and should be able to access `self`
/// and should be avoid copying closures, original closure should be used
///
/// This is an adapter pattern for the high level HTTP requests transport
public protocol HTTPAdapter: AnyObject {
    associatedtype TYPE: ResponseType
    associatedtype SRV: ServerDescription
    associatedtype RXI: RxInterface
    init(_ handlerType: HttpKit.ResponseHandlingApi<TYPE, SRV, RXI>)
    
    func performRequest(_ request: URLRequest,
                        sucessCodes: [Int])
    /// Should be the main closure which should call basic closure and Rx stuff (observer, lifetime) and Async stuff
    /// This is not defined in ResponseHandlingApi because it is a value type and this function should capture self
    /// So, better to store it here in reference type
    func wrapperHandler() -> (Result<TYPE, HttpKit.HttpError>) -> Void
    /// Should refer to simple closure api
    var handlerType: HttpKit.ResponseHandlingApi<TYPE, SRV, RXI> { get set }
    
    /* mutating */ func transferToCombineState(_ promise: @escaping Future<TYPE, HttpKit.HttpError>.Promise,
                                               _ endpoint: HttpKit.Endpoint<TYPE, SRV>)
}
