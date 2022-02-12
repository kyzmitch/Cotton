//
//  DummyRxInterface.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 2/12/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

/// These types are needed for Combine interfaces of HttpKit.Client we don't have to pass actual ReactiveSwift types
/// to be able to use Combine interfaces
extension HttpKit {
    struct DummyRxObserver: RxAnyObserver {
        typealias R = VoidResponse
        
        public func newSend(value: R) {}
        public func newSend(error: HttpKit.HttpError) {}
    }
    
    struct DummyRxLifetime: RxAnyLifetime {
        func newObserveEnded(_ action: @escaping () -> Void) {}
    }
    
    class DummyRxType<SS: ServerDescription,
                       RX: RxAnyObserver>: RxInterface where RX.R == VoidResponse {
        typealias RO = DummyRxObserver
        typealias S = SS
        
        var observer: HttpKit.DummyRxObserver {
            return .init()
        }
        
        var lifetime: RxAnyLifetime {
            return DummyRxLifetime()
        }
        
        var endpoint: HttpKit.Endpoint<HttpKit.VoidResponse, S> {
            return .init(method: .get, path: "", headers: nil, encodingMethod: .httpBodyJSON(parameters: [:]))
        }
        
        static func == (lhs: HttpKit.DummyRxType<SS, RX>, rhs: HttpKit.DummyRxType<SS, RX>) -> Bool {
            return false
        }
        
        func hash(into hasher: inout Hasher) {}
    }
}
