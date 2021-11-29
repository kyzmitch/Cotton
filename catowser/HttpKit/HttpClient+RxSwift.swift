//
//  HttpClient+RxSwift.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 11/29/21.
//  Copyright © 2021 andreiermoshin. All rights reserved.
//

import Foundation
import Alamofire
import ReactiveSwift

extension HttpKit.Client {
    private func makeRequest<T: ResponseType>(for endpoint: HttpKit.Endpoint<T, Server>,
                                              withAccessToken accessToken: String?,
                                              responseType: T.Type) -> SignalProducer<T, HttpKit.HttpError> {
        let producer: SignalProducer<T, HttpKit.HttpError> = .init { [weak self] (observer, lifetime) in
            guard let self = self else {
                observer.send(error: .zombieSelf)
                return
            }
            guard let url = endpoint.url(relatedTo: self.server) else {
                observer.send(error: .failedConstructUrl)
                return
            }
            
            let httpRequest: URLRequest
            do {
                httpRequest = try endpoint.request(url, httpTimeout: self.httpTimeout, accessToken: accessToken)
            } catch let error as HttpKit.HttpError {
                observer.send(error: error)
                return
            } catch {
                observer.send(error: .httpFailure(error: error))
                return
            }
            
            let codes = T.successCodes
            
            let dataRequest: DataRequest = AF.request(httpRequest)
            dataRequest
                .validate(statusCode: codes)
                .responseDecodable(of: responseType,
                                   queue: .main,
                                   decoder: JSONDecoder(),
                                   completionHandler: { (response) in
                    switch response.result {
                    case .success(let value):
                        observer.send(value: value)
                        observer.sendCompleted()
                    case .failure(let error):
                        observer.send(error: .httpFailure(error: error))
                    }
                })
            
            lifetime.observeEnded({
                dataRequest.cancel()
            })
        }
        
        return producer
    }
    
    public func makePublicRequest<T: ResponseType>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                   responseType: T.Type) -> SignalProducer<T, HttpKit.HttpError> {
        let producer = makeRequest(for: endpoint, withAccessToken: nil, responseType: responseType)
        return producer
    }
    
    public func makeAuthorizedRequest<T: ResponseType>(for endpoint: HttpKit.Endpoint<T, Server>,
                                                       withAccessToken accessToken: String,
                                                       responseType: T.Type) -> SignalProducer<T, HttpKit.HttpError> {
        let producer = makeRequest(for: endpoint, withAccessToken: accessToken, responseType: responseType)
        return producer
    }
    
    func makeVoidRequest(for endpoint: HttpKit.VoidEndpoint<Server>,
                         withAccessToken accessToken: String?) -> SignalProducer<Void, HttpKit.HttpError> {
        let producer: SignalProducer<Void, HttpKit.HttpError> = .init { [weak self] (observer, lifetime) in
            guard let self = self else {
                observer.send(error: .zombieSelf)
                return
            }
            guard let url = endpoint.url(relatedTo: self.server) else {
                observer.send(error: .failedConstructUrl)
                return
            }
            
            let httpRequest: URLRequest
            do {
                httpRequest = try endpoint.request(url, httpTimeout: self.httpTimeout, accessToken: accessToken)
            } catch let error as HttpKit.HttpError {
                observer.send(error: error)
                return
            } catch {
                observer.send(error: .httpFailure(error: error))
                return
            }
            
            let codes = HttpKit.VoidResponse.successCodes
            let dataRequest: DataRequest = AF.request(httpRequest)
            dataRequest
                .validate(statusCode: codes)
                .response { (defaultResponse) in
                    if let error = defaultResponse.error {
                        let localError = HttpKit.HttpError.httpFailure(error: error)
                        observer.send(error: localError)
                    } else {
                        let value: Void = ()
                        observer.send(value: value)
                        observer.sendCompleted()
                    }
            }
            
            lifetime.observeEnded({
                dataRequest.cancel()
            })
        }
        return producer
    }
}
