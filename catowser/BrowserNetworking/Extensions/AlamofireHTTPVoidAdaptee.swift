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

final class AlamofireHTTPVoidAdaptee: HTTPNetworkingBackendVoid {
    var wrapperHandler: ((Result<Void, HttpKit.HttpError>) -> Void)
    
    var handlerType: ResponseVoidHandlingApi
    
    init(_ handlerType: ResponseVoidHandlingApi) {
        self.handlerType = handlerType
        wrapperHandler = handlerType.wrapperHandler
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
                self?.wrapperHandler(result)
        }
        if case let .rxObserver(_, lifetime) = handlerType {
            lifetime.observeEnded({
                dataRequest.cancel()
            })
        } else if case let .combine(_) = handlerType {
            // https://github.com/kyzmitch/Cotton/issues/14
        }
    }
    
    func transferToRxState(_ observer: Signal<Void, HttpKit.HttpError>.Observer, _ lifetime: Lifetime) {
        if case .waitsForRxObserver = handlerType {
            handlerType = .rxObserver(observer, lifetime)
        }
    }
    
    func transferToCombineState(_ promise: @escaping Future<Void, HttpKit.HttpError>.Promise) {
        if case .waitsForCombinePromise = handlerType {
            handlerType = .combine(promise)
        }
    }
}
