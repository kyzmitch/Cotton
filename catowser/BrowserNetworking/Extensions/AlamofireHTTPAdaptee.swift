//
//  AlamofireHTTPAdaptee.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 11/29/21.
//  Copyright © 2021 andreiermoshin. All rights reserved.
//

import HttpKit
import Alamofire
import ReactiveSwift
#if canImport(Combine)
import Combine
#endif

final class AlamofireHTTPAdaptee<RType: ResponseType, SType: ServerDescription>: HTTPAdapter {
    typealias TYPE = RType
    typealias SRV = SType
    
    var handlerType: HttpKit.ResponseHandlingApi<RType, SType>
    
    init(_ handlerType: HttpKit.ResponseHandlingApi<RType, SType>) {
        self.handlerType = handlerType
    }
    
    func wrapperHandler() -> (Result<RType, HttpKit.HttpError>) -> Void {
        let closure = { [weak self] (result: Result<TYPE, HttpKit.HttpError>) in
            guard let self = self else {
                return
            }
            switch self.handlerType {
            case .closure(let originalClosure):
                originalClosure.closure(result)
            case .rxObserver(let observerWrapper):
                switch result {
                case .success(let value):
                    observerWrapper.observer.send(value: value)
                case .failure(let error):
                    observerWrapper.observer.send(error: error)
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
    
    func performRequest(_ request: URLRequest, sucessCodes: [Int]) {
        let dataRequest: DataRequest = AF.request(request)
        dataRequest
            .validate(statusCode: sucessCodes)
            .responseDecodable(of: TYPE.self,
                               queue: .main,
                               decoder: JSONDecoder(),
                               completionHandler: { [weak self] (response) in
                let result: Result<TYPE, HttpKit.HttpError>
                switch response.result {
                case .success(let value):
                    result = .success(value)
                case .failure(let error):
                    result = .failure(.httpFailure(error: error))
                }
                guard let self = self else {
                    print("Networking backend was deallocated")
                    return
                }
                self.wrapperHandler()(result)
            })
        if case let .rxObserver(observerWrapper) = handlerType {
            observerWrapper.lifetime.observeEnded({
                dataRequest.cancel()
            })
        } else if case let .combine(_) = handlerType {
            // https://github.com/kyzmitch/Cotton/issues/14
        }
    }
    
    func transferToRxState(_ observer: Signal<TYPE, HttpKit.HttpError>.Observer,
                           _ lifetime: Lifetime,
                           _ endpoint: HttpKit.Endpoint<RType, SType>) {
        if case .waitsForRxObserver = handlerType {
            let observerWrapper: HttpKit.RxObserverWrapper<RType, SType> = .init(observer, lifetime, endpoint)
            handlerType = .rxObserver(observerWrapper)
        }
    }
    
    func transferToCombineState(_ promise: @escaping Future<TYPE, HttpKit.HttpError>.Promise,
                                _ endpoint: HttpKit.Endpoint<RType, SType>) {
        if case .waitsForCombinePromise = handlerType {
            let promiseWrapper: HttpKit.CombinePromiseWrapper<RType, SType> = .init(promise, endpoint)
            handlerType = .combine(promiseWrapper)
        }
    }
}

/// Wrapper around Alamofire method
extension URLRequest: URLRequestCreatable {
    public func convertToURLRequest() throws -> URLRequest {
        return try asURLRequest()
    }
}

/// Wrapper around Alamofire method
extension JSONEncoding: JSONRequestEncodable {
    public func encodeRequest(_ urlRequest: URLRequestCreatable, with parameters: [String: Any]?) throws -> URLRequest {
        return try encode(urlRequest.convertToURLRequest(), with: parameters)
    }
}
