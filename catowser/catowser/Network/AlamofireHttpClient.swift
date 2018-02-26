//
//  AlamofireHttpClient.swift
//  catowser
//
//  Created by Andrey Ermoshin on 25/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//

import Foundation
import Alamofire

fileprivate extension HttpRequestType {
    func alamofireType() -> HTTPMethod {
        switch self {
        case .GET:
            return .get
        case .POST:
            return .post
        }
    }
}

class AlamofireHttpClient: NSObject, HttpApi {
    
    typealias ResponseData = Data
    
    var userAgent: String
    var acceptHeader: String
    var defaultTimeout: TimeInterval
    var endpointState: EndpointUrlState
    
    private weak var request: Request?
    
    private lazy var alamofire: SessionManager = {
        let configuration = URLSessionConfiguration.ephemeral
        var defaultHeaders = SessionManager.default.session.configuration.httpAdditionalHeaders ?? [:]
        configuration.httpAdditionalHeaders = httpHeaders
        return SessionManager(configuration: configuration)
    }()
    
    private lazy var httpHeaders: HTTPHeaders = {
        let dictionary = ["User-Agent": userAgent,
                          "Accept": acceptHeader]
        return dictionary
    }()
    
    required init(endpointAddressString: String?, acceptHeaderString: String, timeout: TimeInterval = NetworkConstants.requestTimeout) {
        defaultTimeout = timeout
        userAgent = NetworkConstants.userAgentName
        acceptHeader = acceptHeaderString
        
        endpointState = .NeedFullUrl
        super.init()
        setEndpointState(with: endpointAddressString)
    }
    
    func sendRequest(type: HttpRequestType, path: String, responseCallback: @escaping (HttpResponseData<Data>) -> Void) {
        
        var constructedUrl: URL?
        
        if case let .NeedUrlSuffix(endpointUrl) = endpointState {
            constructedUrl = URL(string: path, relativeTo: endpointUrl)
        }
        else {
            responseCallback(.error(.EndpointIsNotSet))
            return
        }
        
        guard let requestUrl = constructedUrl else {
            responseCallback(.error(.InvalidUrl))
            return
        }
        
        request = alamofire.request(requestUrl.absoluteString, method: type.alamofireType(), parameters: nil, encoding: URLEncoding.default, headers: nil).validate(statusCode: 200..<300).responseData(completionHandler: { response in
            if let urlResponseError = response.result.error {
                responseCallback(.error(.ResponseError(urlResponseError)))
                return
            }
            
            if let responseData = response.result.value {
                responseCallback(.success(responseData))
            }
            else {
                responseCallback(.error(.EmptyData))
            }
        })
    }
}
