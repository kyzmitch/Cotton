//
//  AlamofireHTTPRxAdaptee.swift
//  BrowserNetworking
//
//  Created by Andrei Ermoshin on 11/29/21.
//  Copyright © 2021 andreiermoshin. All rights reserved.
//

import HttpKit
import ReactiveHttpKit
import Alamofire
import ReactiveSwift
#if canImport(Combine)
import Combine
#endif

final class AlamofireHTTPRxAdaptee<R, S, RX: RxInterface>: HTTPRxAdapter where RX.Observer.Response == R, RX.Server == S {
    typealias Response = R
    typealias Server = S
    typealias ObserverWrapper = RX
    
    var handlerType: HttpKit.ResponseHandlingApi<Response, Server, ObserverWrapper>
    
    init(_ handlerType: HttpKit.ResponseHandlingApi<Response, Server, ObserverWrapper>) {
        self.handlerType = handlerType
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
    
    func performRequest(_ request: URLRequest, sucessCodes: [Int]) {
        let dataRequest: DataRequest = AF.request(request)
        dataRequest
            .validate(statusCode: sucessCodes)
            .responseDecodable(of: Response.self,
                               queue: .main,
                               decoder: JSONDecoder(),
                               completionHandler: { [weak self] (response) in
                let result: Result<Response, HttpKit.HttpError>
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
            observerWrapper.lifetime.newObserveEnded({
                dataRequest.cancel()
            })
        } else if case let .combine(_) = handlerType {
            // https://github.com/kyzmitch/Cotton/issues/14
        }
    }
    
    func transferToCombineState(_ promise: @escaping Future<Response, HttpKit.HttpError>.Promise,
                                _ endpoint: HttpKit.Endpoint<Response, Server>) {
        if case .waitsForCombinePromise = handlerType {
            let promiseWrapper: HttpKit.CombinePromiseWrapper<Response, Server> = .init(promise, endpoint)
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