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

public protocol RxAnyVoidObserver {
    func newSend(value: Void)
    func newSend(error: HttpKit.HttpError)
}

public protocol RxVoidInterface: Hashable {
    associatedtype S: ServerDescription
    
    var observer: RxAnyVoidObserver { get }
    var lifetime: RxAnyLifetime { get }
    /// Not needed actually, but maybe we have to use S type somewhere
    var endpoint: HttpKit.VoidEndpoint<S> { get }
}

extension HttpKit {
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public enum ResponseVoidHandlingApi<S, RX: RxVoidInterface> where RX.S == S {
        case closure(ClosureVoidWrapper<S>)
        case rxObserver(RX)
        case waitsForRxObserver
        case combine(CombinePromiseVoidWrapper<S>)
        case waitsForCombinePromise
        case asyncAwaitConcurrency
    }
}
