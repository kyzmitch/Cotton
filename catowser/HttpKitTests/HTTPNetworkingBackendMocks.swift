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
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            let result: Result<TYPE, HttpKit.HttpError> = .failure(.failedConstructUrl)
            self?.completionHandler(result)
        }
    }
}
