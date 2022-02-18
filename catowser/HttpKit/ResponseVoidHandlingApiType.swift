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
    func newComplete()
}

public protocol RxVoidInterface: Hashable {
    associatedtype Server: ServerDescription
    
    var observer: RxAnyVoidObserver { get }
    var lifetime: RxAnyLifetime { get }
    /// Not needed actually, but maybe we have to use S type somewhere
    var endpoint: HttpKit.VoidEndpoint<Server> { get }
}

extension HttpKit {
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public enum ResponseVoidHandlingApi<Server, RX: RxVoidInterface> where RX.Server == Server {
        case closure(ClosureVoidWrapper<Server>)
        case rxObserver(RX)
        case waitsForRxObserver
        case combine(CombinePromiseVoidWrapper<Server>)
        case waitsForCombinePromise
        case asyncAwaitConcurrency
    }
}
