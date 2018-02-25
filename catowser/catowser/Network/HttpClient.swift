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
                                               "Accept": "application/xml,application/json;charset=UTF-8"]
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: queue)
        return session
    }()
    
    private let queue: OperationQueue
    var endpointUrl: URL
    var userAgent: String
    var defaultTimeout: TimeInterval
    
    private weak var currentTask: URLSessionDataTask?
    
    required init?(endpointAddressString: String, timeout: TimeInterval = NetworkConstants.requestTimeout) {
        let url = URL(string: endpointAddressString)
        guard let _ = url else {
            print(#function + ": wrong url string \(endpointAddressString)")
            return nil
        }
        endpointUrl = url!
        defaultTimeout = timeout
        queue = OperationQueue()
        userAgent = NetworkConstants.userAgentName
        super.init()
    }
    
    func sendRequest(type: HttpRequestType, path: String, responseCallback: @escaping HttpResponseCallback<ResponseData>) -> HttpRequestSendError? {
        guard let requestUrl = URL(string: path, relativeTo: endpointUrl) else {
            responseCallback(.error(.InvalidUrl))
            return .InvalidUrl
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
        return nil
    }
}

extension HttpClient: URLSessionDelegate {
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
    }
}
