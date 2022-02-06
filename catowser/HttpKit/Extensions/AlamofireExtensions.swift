//
//  AlamofireExtensions.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 11/29/21.
//  Copyright © 2021 andreiermoshin. All rights reserved.
//

import Alamofire

final class AFNetworkingBackend<RType: ResponseType>: HTTPNetworkingBackend {
    typealias TYPE = RType
    
    let completionHandler: ((Result<TYPE, HttpKit.HttpError>) -> Void)
    
    init(_ handler: @escaping (Result<TYPE, HttpKit.HttpError>) -> Void) {
        completionHandler = handler
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
                self?.completionHandler(result)
            })
    }
}

final class AFNetworkingVoidBackend: HTTPNetworkingBackendVoid {
    
    let completionHandler: ((Result<Void, HttpKit.HttpError>) -> Void)
    
    init(_ handler: @escaping (Result<Void, HttpKit.HttpError>) -> Void) {
        completionHandler = handler
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
                self?.completionHandler(result)
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
    public func encodeRequest(_ urlRequest: URLRequestCreatable, with parameters: [String : Any]?) throws -> URLRequest {
        return try encode(urlRequest.convertToURLRequest(), with: parameters)
    }
}
