//
//  HttpClient.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/11/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation
import Alamofire
import ReactiveSwift

/// Main namespace for Kit
public enum HttpKit {}

extension HttpKit {
    public class Client<Server: ServerDescription> {
        private let server: Server
        
        private let connectivityManager: NetworkReachabilityManager?
        
        private let httpTimeout: TimeInterval
        
        private lazy var hostListener: Alamofire.NetworkReachabilityManager.Listener = { [weak self] status in
            guard let self = self else {
                return
            }
            // TODO: set connectionStateStream.value
        }
        
        public init(server: Server, httpTimeout: TimeInterval = 60) {
            self.server = server
            self.httpTimeout = httpTimeout
            
            if let manager = NetworkReachabilityManager(host: server.hostString) {
                connectivityManager = manager
            } else if let manager = NetworkReachabilityManager() {
                connectivityManager = manager
            } else {
                connectivityManager = nil
                assertionFailure("No connectivity manager for: \(server.hostString)")
            }
            
            connectivityManager?.listener = hostListener
            _ = connectivityManager?.startListening()
        }
        
        private func makeRequest<T: ResponseType>(for endpoint: Endpoint<T, Server>,
                                               withAccessToken accessToken: String?,
                                               responseType: T.Type) -> SignalProducer<T, HttpError> {
            let producer: SignalProducer<T, HttpError> = .init { [weak self] (observer, lifetime) in
                guard let self = self else {
                    observer.send(error: .zombySelf)
                    return
                }
                guard let url = endpoint.url(self.server) else {
                    observer.send(error: .failedConstructUrl)
                    return
                }
                
                var httpRequest = URLRequest(url: url,
                                             cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                             timeoutInterval: self.httpTimeout)
                httpRequest.httpMethod = endpoint.method.rawValue
                httpRequest.allHTTPHeaderFields = endpoint.headers?.dictionary
                if let token = accessToken {
                    let auth: HttpHeader = .authorization(token: token)
                    httpRequest.setValue(auth.value, forHTTPHeaderField: auth.key)
                }
                
                do {
                     try httpRequest.addParameters(from: endpoint)
                } catch let error as HttpError {
                    observer.send(error: error)
                    return
                } catch {
                    observer.send(error: .httpFailure(error: error, request: httpRequest))
                    return
                }
                
                let codes = T.successCodes
                
                let dataRequest: DataRequest = Alamofire.request(httpRequest)
                    .validate(statusCode: codes)
                    .responseDecodableObject(queue: nil, completionHandler: { (response: DataResponse<T>) in
                        switch response.result {
                        case .success(let value):
                            observer.send(value: value)
                            observer.sendCompleted()
                        case .failure(let error) where error is HttpKit.HttpError:
                            let kitError = error as! HttpError
                            observer.send(error: kitError)
                        case .failure(let error):
                            observer.send(error: .httpFailure(error: error, request: httpRequest))
                        }
                    })
                
                lifetime.observeEnded({
                    dataRequest.cancel()
                })
            }
            
            return producer
        }
        
        func makePublicRequest<T: ResponseType>(for endpoint: Endpoint<T, Server>,
                                             responseType: T.Type) -> SignalProducer<T, HttpError> {
            let producer = makeRequest(for: endpoint, withAccessToken: nil, responseType: responseType)
            return producer
        }
        
        func makeAuthorizedRequest<T: ResponseType>(for endpoint: Endpoint<T, Server>,
                                                 withAccessToken accessToken: String,
                                                 responseType: T.Type) -> SignalProducer<T, HttpError> {
            let producer = makeRequest(for: endpoint, withAccessToken: accessToken, responseType: responseType)
            return producer
        }
    }
}

extension URLRequest {
    mutating func addParameters<T: Decodable, S: ServerDescription>(from endpoint: HttpKit.Endpoint<T, S>)  throws {
        switch endpoint.encodingMethod {
        case .httpBodyJSON(parameters: let parameters):
            do {
                self = try JSONEncoding.default.encode(self, with: parameters)
            } catch {
                throw HttpKit.HttpError.failedEncodeJSONRequestParameters(error)
            }
        case .httpBody(encodedData: let encodedData):
            let contentHeader: HttpKit.HttpHeader = .contentType(.json)
            setValue(contentHeader.value, forHTTPHeaderField: contentHeader.key)
            httpBody = encodedData
        case .queryString:
            let contentHeader: HttpKit.HttpHeader = .contentType(.url)
            setValue(contentHeader.value, forHTTPHeaderField: contentHeader.key)
        }
    }
}
