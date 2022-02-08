//
//  NetworkingBackend.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 2/8/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import ReactiveSwift
#if canImport(Combine)
import Combine
#endif

/// Combine Future type is only available from ios 13 https://stackoverflow.com/a/68754297
/// Can't mark specific enum case to be available for certain OS version
/// Deployment target was set to 13.0 from 12.1 from now
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public enum ResponseHandlingApi<TYPE: ResponseType> {
    case closure((Result<TYPE, HttpKit.HttpError>) -> Void)
    case rxObserver(Signal<TYPE, HttpKit.HttpError>.Observer, Lifetime)
    case waitsForRxObserver
    case combine(Future<TYPE, HttpKit.HttpError>.Promise)
    case waitsForCombinePromise
    case asyncAwaitConcurrency
    
    public var wrapperHandler: ((Result<TYPE, HttpKit.HttpError>) -> Void) {
        let closure = { (result: Result<TYPE, HttpKit.HttpError>) in
            switch self {
            case .closure(let originalClosure):
                originalClosure(result)
            case .rxObserver(let observer, _):
                switch result {
                case .success(let value):
                    observer.send(value: value)
                case .failure(let error):
                    observer.send(error: error)
                }
            case .waitsForRxObserver, .waitsForCombinePromise:
                break
            case .combine(let promise):
                promise(result)
            case .asyncAwaitConcurrency:
                break
            }
        }
        return closure
    }
}

@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public enum ResponseVoidHandlingApi {
    case closure((Result<Void, HttpKit.HttpError>) -> Void)
    case rxObserver(Signal<Void, HttpKit.HttpError>.Observer, Lifetime)
    case waitsForRxObserver
    case combine(Future<Void, HttpKit.HttpError>.Promise)
    case waitsForCombinePromise
    case asyncAwaitConcurrency
    
    public var wrapperHandler: ((Result<Void, HttpKit.HttpError>) -> Void) {
        let closure = { (result: Result<Void, HttpKit.HttpError>) in
            switch self {
            case .closure(let originalClosure):
                originalClosure(result)
            case .rxObserver(let observer, _):
                switch result {
                case .success():
                    let value: Void = ()
                    observer.send(value: value)
                case .failure(let error):
                    observer.send(error: error)
                }
            case .waitsForRxObserver, .waitsForCombinePromise:
                break
            case .combine(let promise):
                promise(result)
            case .asyncAwaitConcurrency:
                break
            }
        }
        return closure
    }
}

/// Interface for some HTTP networking library (e.g. Alamofire) to hide it and
/// not use it directly and be able to mock it for unit testing.
/// Also, it allows to use completely different callback APIs (closure, Reactive observers, Combine promises, etc.
/// It seems it should be only implemented by classes (see AnyObject requirement),
/// because network library API probably uses closures and should be able to access `self`
/// and should be avoid copying closures, original closure should be used
public protocol HTTPNetworkingBackend: AnyObject {
    associatedtype TYPE: ResponseType
    init(_ handlerType: ResponseHandlingApi<TYPE>)
    
    func performRequest(_ request: URLRequest,
                        sucessCodes: [Int])
    /// Should be the main closure which should call basic closure and Rx stuff (observer, lifetime) and Async stuff
    var wrapperHandler: ((Result<TYPE, HttpKit.HttpError>) -> Void) { get }
    /// Should refer to simple closure api
    var handlerType: ResponseHandlingApi<TYPE> { get }
    
    /* mutating */ func transferToRxState(_ observer: Signal<TYPE, HttpKit.HttpError>.Observer, _ lifetime: Lifetime)
    /* mutating */ func transferToCombineState(_ promise: @escaping Future<TYPE, HttpKit.HttpError>.Promise)
}

public protocol HTTPNetworkingBackendVoid: AnyObject {
    init(_ handlerType: ResponseVoidHandlingApi)
    func performVoidRequest(_ request: URLRequest,
                            sucessCodes: [Int])
    var wrapperHandler: ((Result<Void, HttpKit.HttpError>) -> Void) { get }
    var handlerType: ResponseVoidHandlingApi { get }
    
    /* mutating */ func transferToRxState(_ observer: Signal<Void, HttpKit.HttpError>.Observer, _ lifetime: Lifetime)
    /* mutating */ func transferToCombineState(_ promise: @escaping Future<Void, HttpKit.HttpError>.Promise)
}
