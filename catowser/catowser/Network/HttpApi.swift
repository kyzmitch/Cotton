//
//  HttpApi.swift
//  catowser
//
//  Created by Andrey Ermoshin on 25/02/2018.
//  Copyright © 2018 andreiermoshin. All rights reserved.
//

import Foundation

enum HttpRequestType {
    case GET
    case POST
}

enum HttpRequestSendError: Error {
    case InvalidUrl
    case EndpointIsNotSet
    case EmptyData
    case ResponseError(Error)
}

enum HttpResponseData<T> {
    case error(HttpRequestSendError)
    case success(T)
}

typealias HttpResponseCallback<T> = (_ response: HttpResponseData<T>) -> Void

enum EndpointUrlState {
    case NeedFullUrl
    // URL is an endpoint main address like "https://google.com"
    case NeedUrlSuffix(URL)
}

protocol HttpApi: class {
    associatedtype ResponseData
    var acceptHeader: String {get set}
    var userAgent: String {get set}
    var defaultTimeout: TimeInterval {get set}
    var endpointState: EndpointUrlState {get set}
    
    init(endpointAddressString: String?, acceptHeaderString: String, timeout: TimeInterval)
    func sendRequest(type: HttpRequestType, path: String, responseCallback: @escaping HttpResponseCallback<ResponseData>)
}

extension HttpApi {
    func setEndpointState(with endpointAddressString: String?) {
        if let address = endpointAddressString {
            if let url = URL(string: address) {
                endpointState = .NeedUrlSuffix(url)
            }
            else {
                print(#function + ": wrong url string \(address)")
                endpointState = .NeedFullUrl
            }
        }
        else {
            endpointState = .NeedFullUrl
        }
    }
}
