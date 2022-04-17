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
    // gryphon ignore
    public struct DummyRxObserver<RR: ResponseType>: RxAnyObserver {
        public typealias Response = RR
        
        public func newSend(value: Response) {}
        public func newSend(error: HttpKit.HttpError) {}
        public func newComplete() {}
    }
    
    // gryphon ignore
    struct DummyRxLifetime: RxAnyLifetime {
        func newObserveEnded(_ action: @escaping () -> Void) {}
    }
    
    // gryphon ignore
    public class DummyRxType<R,
                             SS: ServerDescription,
                             RX: RxAnyObserver>: RxInterface where RX.Response == R {
        public typealias Observer = RX
        public typealias Server = SS
        
        public var observer: RX {
            // TODO: think about why it ask for conversion
            // swiftlint:disable:next force_cast
            return DummyRxObserver<R>() as! RX
        }
        
        public var lifetime: RxAnyLifetime {
            return DummyRxLifetime()
        }
        
        public var endpoint: HttpKit.Endpoint<R, Server> {
            return .init(method: .get, path: "", headers: nil, encodingMethod: .httpBodyJSON(parameters: [:]))
        }
        
        public static func == (lhs: HttpKit.DummyRxType<R, SS, RX>, rhs: HttpKit.DummyRxType<R, SS, RX>) -> Bool {
            return lhs.endpoint == rhs.endpoint
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine("DummyRxType")
            hasher.combine(endpoint)
        }
    }
}
