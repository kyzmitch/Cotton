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
    case EmptyData
    case ResponseError(Error)
}

enum HttpResponseData<T> {
    case error(HttpRequestSendError)
    case success(T)
}

typealias HttpResponseCallback<T> = (_ response: HttpResponseData<T>) -> Void

protocol HttpApi: class {
    associatedtype ResponseData
    var userAgent: String {get set}
    var defaultTimeout: TimeInterval {get set}
    var endpointUrl: URL {get set}
    
    init?(endpointAddressString: String, timeout: TimeInterval)
    func sendRequest(type: HttpRequestType, path: String, responseCallback: @escaping HttpResponseCallback<ResponseData>) -> HttpRequestSendError?
}

