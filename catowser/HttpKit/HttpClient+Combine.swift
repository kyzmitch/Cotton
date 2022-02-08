//
//  HttpClient+Combine.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 4/28/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import Alamofire // TODO: replace on closure methods
#if canImport(Combine)
import Combine
#endif

extension HttpKit.Client {
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public typealias ResponseFuture<T> = Deferred<Future<T, HttpKit.HttpError>>
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    private func cMakeRequest<T: ResponseType>(for endpoint: HttpKit.Endpoint<T, Server>,
                                               withAccessToken accessToken: String?,
                                               responseType: T.Type) -> ResponseFuture<T> {
        return Combine.Deferred {
            let subject: Future<T, HttpKit.HttpError> = .init { (promise) in
                guard let url = endpoint.url(relatedTo: self.server) else {
                    promise(.failure(.failedConstructUrl))
                    return
                }
                
                let httpRequest: URLRequest
                do {
                    httpRequest = try endpoint.request(url,
                                                       httpTimeout: self.httpTimeout,
                                                       jsonEncoder: self.jsonEncoder,
                                                       accessToken: accessToken)
                } catch let error as HttpKit.HttpError {
                    promise(.failure(error))
                    return
                } catch {
                    promise(.failure(.httpFailure(error: error)))
                    return
                }
                
                let codes = T.successCodes
                
                let _: DataRequest = AF.request(httpRequest)
                    .validate(statusCode: codes)
                    .responseDecodable(of: responseType,
                                       queue: .main,
                                       decoder: JSONDecoder(),
                                       completionHandler: { (response) in
                        switch response.result {
                        case .success(let value):
                            promise(.success(value))
                        case .failure(let error):
                            promise(.failure(.httpFailure(error: error)))
                        }
                    })
                
                // https://github.com/kyzmitch/Cotton/issues/14
            }
            return subject
        }
    }
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func cMakePublicRequest<T: ResponseType>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                    responseType: T.Type) -> ResponseFuture<T> {
        let future = cMakeRequest(for: endpoint,
                                  withAccessToken: nil,
                                  responseType: responseType)
        return future
    }
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func cMakeAuthorizedRequest<T: ResponseType>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                        withAccessToken accessToken: String,
                                                        responseType: T.Type) -> ResponseFuture<T> {
        let future = cMakeRequest(for: endpoint,
                                  withAccessToken: accessToken,
                                  responseType: responseType)
        return future
    }
}
