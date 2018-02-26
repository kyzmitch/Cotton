//
//  HttpClient.swift
//  catowser
//
//  Created by Andrey Ermoshin on 24/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//

import Foundation

class HttpClient: NSObject, HttpApi {
    
    typealias ResponseData = Data
    
    private lazy var httpSession: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.httpAdditionalHeaders = ["User-Agent": userAgent,
                                               "Accept": acceptHeader]
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: queue)
        return session
    }()
    
    private let queue: OperationQueue
    var endpointState: EndpointUrlState
    var userAgent: String
    var acceptHeader: String
    var defaultTimeout: TimeInterval
    
    private weak var currentTask: URLSessionDataTask?
    
    required init(endpointAddressString: String?, acceptHeaderString: String, timeout: TimeInterval = NetworkConstants.requestTimeout) {
        defaultTimeout = timeout
        queue = OperationQueue()
        acceptHeader = acceptHeaderString
        userAgent = NetworkConstants.userAgentName
        
        endpointState = .NeedFullUrl
        super.init()
        setEndpointState(with: endpointAddressString)
    }
    
    func sendRequest(type: HttpRequestType, path: String, responseCallback: @escaping HttpResponseCallback<ResponseData>) {
        
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
        
        let request = URLRequest(url: requestUrl, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: defaultTimeout)
        
        currentTask = httpSession.dataTask(with: request) { (data, response, error) in
            if let urlResponseError = error {
                responseCallback(.error(.ResponseError(urlResponseError)))
            }
            else {
                // Parsing should be implemented on next upper levels
                if let responseData = data {
                    responseCallback(.success(responseData))
                }
                else {
                    responseCallback(.error(.EmptyData))
                }
            }
        }
        
        currentTask?.resume()
        return
    }
}

extension HttpClient: URLSessionDelegate {
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
    }
}
