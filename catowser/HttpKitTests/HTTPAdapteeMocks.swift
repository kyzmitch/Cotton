//
//  HTTPAdapteeMocks.swift
//  HttpKitTests
//
//  Created by Andrei Ermoshin on 1/25/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
@testable import HttpKit
import Combine
import CoreHttpKit

final class MockedHTTPAdapteeWithFail<R, S, RX: RxInterface>: HTTPRxAdapter where RX.Observer.Response == R, RX.Server == S {
    typealias Response = R
    typealias Server = S
    typealias ObserverWrapper = RX
    
    var handlerType: HttpKit.ResponseHandlingApi<Response, Server, ObserverWrapper>
    
    init(_ handlerType: HttpKit.ResponseHandlingApi<Response, Server, ObserverWrapper>) {
        self.handlerType = handlerType
    }
    
    func performRequest(_ request: URLRequest, sucessCodes: [Int]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let nsError: NSError = .init(domain: "URLSession", code: 101, userInfo: nil)
            let result: Result<Response, HttpKit.HttpError> = .failure(.httpFailure(error: nsError))
            self?.wrapperHandler()(result)
        }
    }
    
    func wrapperHandler() -> (Result<Response, HttpKit.HttpError>) -> Void {
        let closure = { [weak self] (result: Result<Response, HttpKit.HttpError>) in
            guard let self = self else {
                return
            }
            switch self.handlerType {
            case .closure(let originalClosure):
                originalClosure.closure(result)
            case .rxObserver(let observerWrapper):
                switch result {
                case .success(let value):
                    observerWrapper.observer.newSend(value: value)
                    observerWrapper.observer.newComplete()
                case .failure(let error):
                    observerWrapper.observer.newSend(error: error)
                }
            case .waitsForRxObserver, .waitsForCombinePromise:
                break
            case .combine(let promiseWrapper):
                promiseWrapper.promise(result)
            case .asyncAwaitConcurrency:
                break
            }
        }
        return closure
    }
    
    func transferToCombineState(_ promise: @escaping Future<Response, HttpKit.HttpError>.Promise,
                                _ endpoint: Endpoint<Server>) {
        
    }
}
