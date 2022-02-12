//
//  ResponseVoidHandlingApiType.swift
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
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public enum ResponseVoidHandlingApi<S: ServerDescription> {
        case closure(ClosureVoidWrapper<S>)
        case rxObserver(RxObserverVoidWrapper<S>)
        case waitsForRxObserver
        case combine(CombinePromiseVoidWrapper<S>)
        case waitsForCombinePromise
        case asyncAwaitConcurrency
    }
}
