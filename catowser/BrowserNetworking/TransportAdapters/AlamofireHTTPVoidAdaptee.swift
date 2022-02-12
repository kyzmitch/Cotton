//
//  AlamofireHTTPVoidAdaptee.swift
//  BrowserNetworking
//
//  Created by Andrei Ermoshin on 2/10/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import HttpKit
import Alamofire
import ReactiveSwift
#if canImport(Combine)
import Combine
#endif

final class AlamofireHTTPVoidAdaptee<S, RX: RxVoidInterface>: HTTPVoidAdapter where RX.S == S {
    typealias SRV = S
    typealias RXI = RX

    var handlerType: HttpKit.ResponseVoidHandlingApi<SRV, RXI>
    
    init(_ handlerType: HttpKit.ResponseVoidHandlingApi<SRV, RXI>) {
        self.handlerType = handlerType
    }
    
    func wrapperHandler() -> (Result<Void, HttpKit.HttpError>) -> Void {
        let closure = { [weak self] (result: Result<Void, HttpKit.HttpError>) in
            guard let self = self else {
                return
            }
            switch self.handlerType {
            case .closure(let originalClosure):
                originalClosure.closure(result)
            case .rxObserver(let observerWrapper):
                switch result {
                case .success:
                    let value: Void = ()
                    observerWrapper.observer.newSend(value: value)
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
    
    func performVoidRequest(_ request: URLRequest, sucessCodes: [Int]) {
        let dataRequest: DataRequest = AF.request(request)
        dataRequest
            .validate(statusCode: sucessCodes)
            .response { [weak self] (defaultResponse) in
                let result: Result<Void, HttpKit.HttpError>
                if let error = defaultResponse.error {
                    let localError = HttpKit.HttpError.httpFailure(error: error)
                    result = .failure(localError)
                } else {
                    let value: Void = ()
                    result = .success(value)
                }
                self?.wrapperHandler()(result)
        }
        if case let .rxObserver(observerWrapper) = handlerType {
            observerWrapper.lifetime.newObserveEnded({
                dataRequest.cancel()
            })
        } else if case let .combine(_) = handlerType {
            // https://github.com/kyzmitch/Cotton/issues/14
        }
    }
    
    func transferToCombineState(_ promise: @escaping Future<Void, HttpKit.HttpError>.Promise,
                                _ endpoint: HttpKit.VoidEndpoint<SRV>) {
        if case .waitsForCombinePromise = handlerType {
            let promiseWrapper: HttpKit.CombinePromiseVoidWrapper<SRV> = .init(promise, endpoint)
            handlerType = .combine(promiseWrapper)
        }
    }
}