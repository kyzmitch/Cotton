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
    var defaultTimeout: TimeInterval
    var endpointUrl: URL
    
    private weak var request: Request?
    
    private lazy var alamofire: SessionManager = {
        let configuration = URLSessionConfiguration.ephemeral
        var defaultHeaders = SessionManager.default.session.configuration.httpAdditionalHeaders ?? [:]
        defaultHeaders["User-Agent"] = userAgent
        configuration.httpAdditionalHeaders = defaultHeaders
        return SessionManager(configuration: configuration)
    }()
    
    private lazy var httpHeaders: HTTPHeaders = {
        let dictionary = ["User-Agent": userAgent,
                          "Accept": "application/xml,application/json;charset=UTF-8"]
        return dictionary
    }()
    
    required init?(endpointAddressString: String, timeout: TimeInterval) {
        let url = URL(string: endpointAddressString)
        guard let _ = url else {
            print(#function + ": wrong url string \(endpointAddressString)")
            return nil
        }
        endpointUrl = url!
        defaultTimeout = timeout
        userAgent = NetworkConstants.userAgentName
        super.init()
    }
    
    func sendRequest(type: HttpRequestType, path: String, responseCallback: @escaping (HttpResponseData<Data>) -> Void) -> HttpRequestSendError? {
        
        guard let requestUrl = URL(string: path, relativeTo: endpointUrl) else {
            responseCallback(.error(.InvalidUrl))
            return .InvalidUrl
        }
        
        request = alamofire.request(requestUrl.absoluteString, method: type.alamofireType(), parameters: nil, encoding: URLEncoding.default, headers: httpHeaders).validate(statusCode: 200..<300).responseData(completionHandler: { response in
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
        
        return nil
    }
}
