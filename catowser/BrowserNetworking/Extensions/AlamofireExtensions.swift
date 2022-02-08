//
//  AlamofireExtensions.swift
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

final class AFNetworkingBackend<RType: ResponseType>: HTTPNetworkingBackend {
    var handlerType: ResponseHandlingApi<RType>
    
    typealias TYPE = RType
    
    init(_ handler: @escaping (Result<RType, HttpKit.HttpError>) -> Void) {
        self.handlerType = ResponseHandlingApi<RType>.closure(handler)
        // TODO: reuse init below
    }
    
    init(_ handlerType: ResponseHandlingApi<RType>) {
        self.handlerType = handlerType
    }
    
    func wrapperHandler() -> (Result<TYPE, HttpKit.HttpError>) -> Void {
        let closure = { [weak self] (result: Result<TYPE, HttpKit.HttpError>) in
            guard let self = self else {
                return
            }
            switch self.handlerType {
            case .closure(let originalClosure):
                originalClosure(result)
            case .rxObserver(let observer, _):
                switch result {
                case .success(let value):
                    observer.send(value: value)
                case .failure(let error):
                    observer.send(error: error)
                }
            case .waitsForRxObserver, .waitsForCombinePromise:
                break
            case .combine(let promise):
                promise(result)
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
        if case let .rxObserver(_, lifetime) = handlerType {
            lifetime.observeEnded({
                dataRequest.cancel()
            })
        } else if case let .combine(_) = handlerType {
            // https://github.com/kyzmitch/Cotton/issues/14
        }
    }
    
    func transferToRxState(_ observer: Signal<TYPE, HttpKit.HttpError>.Observer, _ lifetime: Lifetime) {
        if case .waitsForRxObserver = handlerType {
            handlerType = .rxObserver(observer, lifetime)
        }
    }
    
    func transferToCombineState(_ promise: @escaping Future<TYPE, HttpKit.HttpError>.Promise) {
        if case .waitsForCombinePromise = handlerType {
            handlerType = .combine(promise)
        }
    }
}

final class AFNetworkingVoidBackend: HTTPNetworkingBackendVoid {
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
