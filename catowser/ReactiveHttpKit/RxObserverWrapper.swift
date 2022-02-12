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

extension Lifetime: RxAnyLifetime {}

extension HttpKit {
    public class RxObserverWrapper<RR,
                                   SS: ServerDescription,
                                   RX: RxAnyObserver>: RxInterface where RX.R == RR {
        public typealias RO = RX
        
        public var observer: RO {
            // TODO: it should be recognized by compiler, don't need to force cast
            return rxObserver as! RX
        }
        
        public var lifetime: RxAnyLifetime {
            return rxLifetime
        }
        
        let rxObserver: Signal<RR, HttpKit.HttpError>.Observer
        let rxLifetime: Lifetime
        /// Don't need to use endpoint here, but it is needed to create unique hash value for the closure
        let endpoint: Endpoint<RR, SS>
        let responseType: RR.Type
        
        public init(_ observer: Signal<RR, HttpKit.HttpError>.Observer,
                    _ lifetime: Lifetime,
                    _ endpoint: Endpoint<RR, SS>) {
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
        
        public static func == (lhs: RxObserverWrapper<RR, SS, RX>, rhs: RxObserverWrapper<RR, SS, RX>) -> Bool {
            return lhs.responseType == rhs.responseType && lhs.endpoint == rhs.endpoint
        }
    }
}

extension HttpKit {
    public class RxObserverVoidWrapper<S: ServerDescription>: Hashable {
        public let observer: Signal<Void, HttpKit.HttpError>.Observer
        public let lifetime: Lifetime
        /// Don't need to use endpoint here, but it is needed to create unique hash value for the closure
        let endpoint: VoidEndpoint<S>
        
        public init(_ observer: Signal<Void, HttpKit.HttpError>.Observer,
                    _ lifetime: Lifetime,
                    _ endpoint: VoidEndpoint<S>) {
            self.observer = observer
            self.lifetime = lifetime
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
