//
//  RxObserverWrapper.swift
//  ReactiveHttpKit
//
//  Created by Andrei Ermoshin on 2/12/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import HttpKit
import ReactiveSwift

extension Signal.Observer: RxAnyObserver where Value: ResponseType, Error == HttpKit.HttpError {
    public typealias R = Value
    
    public func newSend(value: Value) {
        send(value: value)
    }
    public func newSend(error: HttpKit.HttpError) {
        send(error: error)
    }
}

extension Signal.Observer: RxAnyVoidObserver where Value == Void, Error == HttpKit.HttpError {
    public func newSend(value: Value) {
        send(value: value)
    }
    public func newSend(error: HttpKit.HttpError) {
        send(error: error)
    }
}

extension Lifetime: RxAnyLifetime {
    public func newObserveEnded(_ action: @escaping () -> Void) {
        observeEnded(action)
    }
}

extension HttpKit {
    public class RxObserverWrapper<RR,
                                   SS: ServerDescription,
                                   RX: RxAnyObserver>: RxInterface where RX.Response == RR {
        public typealias S = SS
        public typealias Observer = RX
        
        public var observer: RX {
            // TODO: it should be recognized by compiler, don't need to force cast
            // swiftlint:disable:next force_cast
            return rxObserver as! RX
        }
        
        public var lifetime: RxAnyLifetime {
            return rxLifetime
        }
        
        let rxObserver: Signal<RR, HttpKit.HttpError>.Observer
        let rxLifetime: Lifetime
        /// Don't need to use endpoint here, but it is needed to create unique hash value for the closure
        public let endpoint: Endpoint<RR, S>
        let responseType: RR.Type
        
        public init(_ observer: Signal<RR, HttpKit.HttpError>.Observer,
                    _ lifetime: Lifetime,
                    _ endpoint: Endpoint<RR, S>) {
            self.rxObserver = observer
            self.rxLifetime = lifetime
            self.endpoint = endpoint
            responseType = RR.self
        }
        
        public func hash(into hasher: inout Hasher) {
            let typeString = String(describing: responseType)
            hasher.combine(typeString)
            hasher.combine("rx.observer")
            hasher.combine(responseType.successCodes)
            hasher.combine(endpoint)
        }
        
        public static func == (lhs: RxObserverWrapper<RR, S, Observer>, rhs: RxObserverWrapper<RR, S, Observer>) -> Bool {
            return lhs.responseType == rhs.responseType && lhs.endpoint == rhs.endpoint
        }
    }
}

extension HttpKit {
    public class RxObserverVoidWrapper<SS: ServerDescription>: RxVoidInterface {
        public typealias S = SS
        
        public var observer: RxAnyVoidObserver {
            return rxObserver
        }
        
        public var lifetime: RxAnyLifetime {
            return rxLifetime
        }
        
        let rxObserver: Signal<Void, HttpKit.HttpError>.Observer
        let rxLifetime: Lifetime
        /// Don't need to use endpoint here, but it is needed to create unique hash value for the closure
        public let endpoint: VoidEndpoint<S>
        
        public init(_ observer: Signal<Void, HttpKit.HttpError>.Observer,
                    _ lifetime: Lifetime,
                    _ endpoint: VoidEndpoint<S>) {
            self.rxObserver = observer
            self.rxLifetime = lifetime
            self.endpoint = endpoint
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine("rx.observer")
            hasher.combine(endpoint)
        }
        
        public static func == (lhs: RxObserverVoidWrapper<S>, rhs: RxObserverVoidWrapper<S>) -> Bool {
            return lhs.endpoint == rhs.endpoint
        }
    }
}
