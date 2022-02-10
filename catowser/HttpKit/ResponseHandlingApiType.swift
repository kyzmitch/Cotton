//
//  ResponseHandlingApiType.swift
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
    /// Combine Future type is only available from ios 13 https://stackoverflow.com/a/68754297
    /// Can't mark specific enum case to be available for certain OS version
    /// Deployment target was set to 13.0 from 12.1 from now
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public enum ResponseHandlingApi<TYPE: ResponseType, S: ServerDescription>: Hashable {
        case closure(ClosureWrapper<TYPE, S>)
        case rxObserver(RxObserverWrapper<TYPE, S>)
        case waitsForRxObserver
        case combine(CombinePromiseWrapper<TYPE, S>)
        case waitsForCombinePromise
        case asyncAwaitConcurrency
        
        // MARK: - convenience methods
        
        public static func closure(_ closure: @escaping (Result<TYPE, HttpKit.HttpError>) -> Void,
                                   _ endpoint: Endpoint<TYPE, S>) -> ResponseHandlingApi<TYPE, S> {
            let closureWrapper: ClosureWrapper<TYPE, S> = .init(closure, endpoint)
            return ResponseHandlingApi<TYPE, S>.closure(closureWrapper)
        }
        
        public func hash(into hasher: inout Hasher) {
            let caseNumber: Int
            switch self {
            case .closure(let closureWrapper):
                caseNumber = 0
                hasher.combine(closureWrapper)
            case .rxObserver(let observerWrapper):
                caseNumber = 1
                hasher.combine(observerWrapper)
            case .waitsForRxObserver:
                caseNumber = 2
            case .waitsForCombinePromise:
                caseNumber = 3
            case .combine(let promiseWrapper):
                caseNumber = 4
                hasher.combine(promiseWrapper)
            case .asyncAwaitConcurrency:
                caseNumber = 5
            }
            hasher.combine(caseNumber)
        }
        
        public static func == (lhs: ResponseHandlingApi<TYPE, S>, rhs: ResponseHandlingApi<TYPE, S>) -> Bool {
            /**
             Can't compare closures/functions and it is intended.
             
             https://stackoverflow.com/a/25694072
             equality of this sort would be extremely surprising in some generics contexts,
             where you can get reabstraction thunks that adjust the actual signature
             of a function to the one the function type expects.
             */
            switch (lhs, rhs) {
            case (.closure(let lClosure), .closure(let rClosure)):
                return lClosure == rClosure
            case (.rxObserver(let lObserver), .rxObserver(let rObserver)):
                return lObserver == rObserver
            case (.waitsForRxObserver, .waitsForRxObserver):
                return true
            case (.combine(let lPromise), .combine(let rPromise)):
                return lPromise == rPromise
            case (.waitsForCombinePromise, .waitsForCombinePromise):
                return true
            case (.asyncAwaitConcurrency, .asyncAwaitConcurrency):
                return true
            default:
                return false
            }
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
