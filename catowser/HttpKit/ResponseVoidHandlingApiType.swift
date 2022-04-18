//
//  ResponseVoidHandlingApiType.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 2/10/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

#if canImport(Combine)
import Combine
#endif
import CoreHttpKit

// gryphon ignore
public protocol RxAnyVoidObserver {
    func newSend(value: Void)
    func newSend(error: HttpKit.HttpError)
    func newComplete()
}

// gryphon ignore
public protocol RxVoidInterface: Hashable {
    associatedtype Server: ServerDescription
    
    var observer: RxAnyVoidObserver { get }
    var lifetime: RxAnyLifetime { get }
    /// Not needed actually, but maybe we have to use S type somewhere
    var endpoint: Endpoint { get }
}

extension HttpKit {
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    // gryphon ignore
    public enum ResponseVoidHandlingApi<Server, Observer: RxVoidInterface>: Hashable where Observer.Server == Server {
        case closure(ClosureVoidWrapper<Server>)
        case rxObserver(Observer)
        case waitsForRxObserver
        case combine(CombinePromiseVoidWrapper<Server>)
        case waitsForCombinePromise
        case asyncAwaitConcurrency
        
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
        
        public static func == (lhs: ResponseVoidHandlingApi<Server, Observer>,
                               rhs: ResponseVoidHandlingApi<Server, Observer>) -> Bool {
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
