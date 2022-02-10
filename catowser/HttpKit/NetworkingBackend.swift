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

public class ClosureWrapper<TYPE: ResponseType>: Hashable {
    public let closure: (Result<TYPE, HttpKit.HttpError>) -> Void
    let responseType: TYPE.Type
    
    init(_ closure: @escaping (Result<TYPE, HttpKit.HttpError>) -> Void) {
        self.closure = closure
        responseType = TYPE.self
    }
    
    public func hash(into hasher: inout Hasher) {
        let typeString = String(describing: responseType)
        hasher.combine(typeString)
        hasher.combine(responseType.successCodes)
    }
    
    public static func == (lhs: ClosureWrapper<TYPE>, rhs: ClosureWrapper<TYPE>) -> Bool {
        return lhs.responseType == rhs.responseType
    }
}

/// Combine Future type is only available from ios 13 https://stackoverflow.com/a/68754297
/// Can't mark specific enum case to be available for certain OS version
/// Deployment target was set to 13.0 from 12.1 from now
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public enum ResponseHandlingApi<TYPE: ResponseType>: Hashable {
    case closure((Result<TYPE, HttpKit.HttpError>) -> Void)
    case rxObserver(Signal<TYPE, HttpKit.HttpError>.Observer, Lifetime)
    case waitsForRxObserver
    case combine(Future<TYPE, HttpKit.HttpError>.Promise)
    case waitsForCombinePromise
    case asyncAwaitConcurrency
    
    public func hash(into hasher: inout Hasher) {
        let caseNumber: Int
        switch self {
        case .closure(let originalClosure):
            caseNumber = 0
        case .rxObserver(let observer, let lifetime):
            caseNumber = 1
        case .waitsForRxObserver:
            caseNumber = 2
        case .waitsForCombinePromise:
            caseNumber = 3
        case .combine(let promise):
            caseNumber = 4
        case .asyncAwaitConcurrency:
            caseNumber = 5
        }
        hasher.combine(caseNumber)
    }
    
    public static func == (lhs: ResponseHandlingApi<TYPE>, rhs: ResponseHandlingApi<TYPE>) -> Bool {
        /**
         Can't compare closures/functions and it is intended.
         
         https://stackoverflow.com/a/25694072
         equality of this sort would be extremely surprising in some generics contexts,
         where you can get reabstraction thunks that adjust the actual signature of a function to the one the function type expects.
         */
        switch (lhs, rhs) {
        case (.closure(_), .closure(_)):
            // TODO: not sure actually, need to check more
            return true
        case (.rxObserver(_, _), rxObserver(_, _)):
            return true
        case (.waitsForRxObserver, .waitsForRxObserver):
            return true
        case (.combine(_), .combine(_)):
            // TODO: not sure actually, need to check more
            return true
        case (.waitsForCombinePromise, .waitsForCombinePromise):
            return true
        case (.asyncAwaitConcurrency, .asyncAwaitConcurrency):
            return true
        default:
            return false
        }
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
    func wrapperHandler() -> (Result<TYPE, HttpKit.HttpError>) -> Void
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
