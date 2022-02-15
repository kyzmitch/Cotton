//
//  ResponseHandlingApiType.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 2/10/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

#if canImport(Combine)
import Combine
#endif

public protocol RxAnyObserver {
    associatedtype Response: ResponseType
    func newSend(value: Response)
    func newSend(error: HttpKit.HttpError)
}

/// Can't add similar Lifetime method because it returns a Disposable which is not a type but protocol already
/// So, can't extend swift protocol like RxAnyDisposable, in other words
/// can't extend swift protocol Disposable with our RxAnyDisposable
/// As a workaround this method doesn't return Disposable
public protocol RxAnyLifetime {
    func newObserveEnded(_ action: @escaping () -> Void)
}

/// This protocol is needed to not use ReactiveSwift dependency directly
/// It should be implemented by RxObserverWrapper which is in different Framework
public protocol RxInterface: Hashable, AnyObject {
    associatedtype RO: RxAnyObserver
    associatedtype S: ServerDescription
    
    var observer: RO { get }
    var lifetime: RxAnyLifetime { get }
    /// Not needed actually, but maybe we have to use S type somewhere
    var endpoint: HttpKit.Endpoint<RO.Response, S> { get }
}

extension HttpKit {
    /// Combine Future type is only available from ios 13 https://stackoverflow.com/a/68754297
    /// Can't mark specific enum case to be available for certain OS version
    /// Deployment target was set to 13.0 from 12.1 from now
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public enum ResponseHandlingApi<R, S, RX: RxInterface>: Hashable where RX.RO.Response == R, RX.S == S {
        case closure(ClosureWrapper<R, S>)
        case rxObserver(RX)
        case waitsForRxObserver
        case combine(CombinePromiseWrapper<R, S>)
        case waitsForCombinePromise
        case asyncAwaitConcurrency
        
        // MARK: - convenience methods
        
        public static func closure(_ closure: @escaping (Result<R, HttpKit.HttpError>) -> Void,
                                   _ endpoint: Endpoint<R, S>) -> ResponseHandlingApi<R, S, RX> {
            let closureWrapper: ClosureWrapper<R, S> = .init(closure, endpoint)
            return ResponseHandlingApi<R, S, RX>.closure(closureWrapper)
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
        
        public static func == (lhs: ResponseHandlingApi<R, S, RX>, rhs: ResponseHandlingApi<R, S, RX>) -> Bool {
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
