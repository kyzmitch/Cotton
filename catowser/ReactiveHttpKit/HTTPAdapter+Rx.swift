//
//  HTTPRxAdapter+Rx.swift
//  ReactiveHttpKit
//
//  Created by Andrei Ermoshin on 2/12/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import HttpKit
import ReactiveSwift

extension HTTPRxAdapter {
    /* mutating */ func transferToRxState(_ observer: Signal<Response, HttpKit.HttpError>.Observer,
                                          _ lifetime: Lifetime,
                                          _ endpoint: HttpKit.Endpoint<Response, Server>) {
        if case .waitsForRxObserver = handlerType {
            let observerWrapper: HttpKit.RxObserverWrapper<Response, Server, ObserverWrapper.Observer> = .init(observer, lifetime, endpoint)
            // TODO: Don't think that this conversion is needed, but lets do it to fix compiler issue
            // swiftlint:disable:next force_cast
            handlerType = .rxObserver(observerWrapper as! Self.ObserverWrapper)
        }
    }
}

extension HTTPVoidAdapter {
    /* mutating */ func transferToRxState(_ observer: Signal<Void, HttpKit.HttpError>.Observer,
                                          _ lifetime: Lifetime,
                                          _ endpoint: HttpKit.VoidEndpoint<Server>) {
        if case .waitsForRxObserver = handlerType {
            let observerWrapper: HttpKit.RxObserverVoidWrapper<Server> = .init(observer, lifetime, endpoint)
            // TODO: Don't think that this conversion is needed, but lets do it to fix compiler issue
            // swiftlint:disable:next force_cast
            handlerType = .rxObserver(observerWrapper as! Self.ObserverWrapper)
        }
    }
}
