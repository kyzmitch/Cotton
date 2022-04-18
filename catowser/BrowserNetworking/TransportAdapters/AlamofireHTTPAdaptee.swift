//
//  AlamofireHTTPAdaptee.swift
//  BrowserNetworking
//
//  Created by Andrey Ermoshin on 18.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import HttpKit
import ReactiveHttpKit
import Alamofire
import ReactiveSwift
#if canImport(Combine)
import Combine
#endif
import CoreHttpKit

final class AlamofireHTTPAdaptee<R: ResponseType, S: ServerDescription>: HTTPAdapter {
    typealias Response = R
    typealias Server = S
    
    var handlerType: HttpKit.ResponseHandlingApi<Response, Server, RxFreeDummy<Response, Server>>
    
    init(_ handlerType: HttpKit.ResponseHandlingApi<Response, Server, RxFreeDummy<Response, Server>>) {
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
            case .rxObserver, .waitsForRxObserver:
                assertionFailure("Calling RX interface in RX free wrapper")
            case .waitsForCombinePromise:
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
        if case let .combine(_) = handlerType {
            // https://github.com/kyzmitch/Cotton/issues/14
        }
    }
    
    func transferToCombineState(_ promise: @escaping Future<Response, HttpKit.HttpError>.Promise,
                                _ endpoint: Endpoint) {
        if case .waitsForCombinePromise = handlerType {
            let promiseWrapper: HttpKit.CombinePromiseWrapper<Response, Server> = .init(promise, endpoint)
            handlerType = .combine(promiseWrapper)
        }
    }
}
