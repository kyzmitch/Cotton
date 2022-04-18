//
//  HttpClient+Kotlin.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 4/16/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CoreHttpKit

extension HttpKit.Client {
    public func makeRequest<T, B: HTTPAdapter>(for endpoint: Endpoint<Server>,
                                                withAccessToken accessToken: String?,
                                                transport adapter: B) where B.Response == T, B.Server == Server {
        let requestInfo = endpoint.request(server: server,
                                           requestTimeout: Int64(httpTimeout),
                                           accessToken: accessToken)
        guard let httpRequest = requestInfo.urlRequest else {
            let result: HttpTypedResult<T> = .failure(.failedKotlinRequestConstruct)
            adapter.wrapperHandler()(result)
            return
        }
        let codes = T.successCodes
        adapter.performRequest(httpRequest, sucessCodes: codes)
    }
    
    // MARK: - Clear RX capable functions without dependencies
    
    public func makeRxRequest<T, B: HTTPRxAdapter>(for endpoint: Endpoint<Server>,
                                                   withAccessToken accessToken: String?,
                                                   transport adapter: B) where B.Response == T, B.Server == Server {
        let requestInfo = endpoint.request(server: server,
                                           requestTimeout: Int64(httpTimeout),
                                           accessToken: accessToken)
        guard let httpRequest = requestInfo.urlRequest else {
            let result: HttpTypedResult<T> = .failure(.failedKotlinRequestConstruct)
            adapter.wrapperHandler()(result)
            return
        }
        
        let codes = T.successCodes
        adapter.performRequest(httpRequest, sucessCodes: codes)
    }
    
    public func makeRxVoidRequest<B: HTTPRxVoidAdapter>(for endpoint: Endpoint<Server>,
                                                        withAccessToken accessToken: String?,
                                                        transport adapter: B) where B.Server == Server {
        let requestInfo = endpoint.request(server: server,
                                           requestTimeout: Int64(httpTimeout),
                                           accessToken: accessToken)
        guard let httpRequest = requestInfo.urlRequest else {
            let result: Result<Void, HttpKit.HttpError> = .failure(.failedKotlinRequestConstruct)
            adapter.wrapperHandler()(result)
            return
        }
        
        let codes = VoidResponse.successCodes
        adapter.performVoidRequest(httpRequest, sucessCodes: codes)
    }
}
