//
//  HTTPAdapter+Rx.swift
//  ReactiveHttpKit
//
//  Created by Andrei Ermoshin on 2/12/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import HttpKit
import ReactiveSwift

extension HTTPAdapter {
    /* mutating */ func transferToRxState(_ observer: Signal<TYPE, HttpKit.HttpError>.Observer,
                                          _ lifetime: Lifetime,
                                          _ endpoint: HttpKit.Endpoint<TYPE, SRV>) {
        if case .waitsForRxObserver = handlerType {
            typealias SignalObserverType = Signal<TYPE, HttpKit.HttpError>.Observer
            let observerWrapper: HttpKit.RxObserverWrapper<TYPE, SRV, SignalObserverType> = .init(observer, lifetime, endpoint)
            handlerType = .rxObserver(observerWrapper)
        }
    }
}

extension HTTPVoidAdapter {
    /* mutating */ func transferToRxState(_ observer: Signal<Void, HttpKit.HttpError>.Observer,
                                          _ lifetime: Lifetime,
                                          _ endpoint: HttpKit.VoidEndpoint<SRV>) {
        if case .waitsForRxObserver = handlerType {
            let observerWrapper: HttpKit.RxObserverVoidWrapper<SRV> = .init(observer, lifetime, endpoint)
            handlerType = .rxObserver(observerWrapper)
        }
    }
}
