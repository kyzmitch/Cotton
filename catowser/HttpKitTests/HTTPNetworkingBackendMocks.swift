//
//  HTTPNetworkingBackendMocks.swift
//  HttpKitTests
//
//  Created by Andrei Ermoshin on 1/25/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
@testable import HttpKit

final class MockedTypedNetworkingBackendWithFail<RType: ResponseType>: HTTPNetworkingBackend {
    typealias TYPE = RType
    
    let completionHandler: ((Result<TYPE, HttpKit.HttpError>) -> Void)
    
    init(_ handler: @escaping (Result<TYPE, HttpKit.HttpError>) -> Void) {
        completionHandler = handler
    }
    
    func performRequest(_ request: URLRequest, sucessCodes: [Int]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let nsError: NSError = .init(domain: "URLSession", code: 101, userInfo: nil)
            let result: Result<TYPE, HttpKit.HttpError> = .failure(.httpFailure(error: nsError))
            self?.completionHandler(result)
        }
    }
}
