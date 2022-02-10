//
//  HTTPNetworkingBackendMocks.swift
//  HttpKitTests
//
//  Created by Andrei Ermoshin on 1/25/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
@testable import HttpKit
import ReactiveSwift
import Combine

final class MockedTypedNetworkingBackendWithFail<RType: ResponseType>: HTTPNetworkingBackend {
    typealias TYPE = RType
    
    let handlerType: ResponseHandlingApi<RType>
    
    init(_ handler: @escaping (Result<RType, HttpKit.HttpError>) -> Void) {
        self.handlerType = ResponseHandlingApi<RType>.closure(handler)
    }
    
    init(_ handlerType: ResponseHandlingApi<RType>) {
        self.handlerType = handlerType
    }
    
    func performRequest(_ request: URLRequest, sucessCodes: [Int]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let nsError: NSError = .init(domain: "URLSession", code: 101, userInfo: nil)
            let result: Result<TYPE, HttpKit.HttpError> = .failure(.httpFailure(error: nsError))
            self?.wrapperHandler()(result)
        }
    }
    
    func wrapperHandler() -> (Result<RType, HttpKit.HttpError>) -> Void {
        let closure = { [weak self] (result: Result<TYPE, HttpKit.HttpError>) in
        }
        return closure
    }
    
    func transferToRxState(_ observer: Signal<RType, HttpKit.HttpError>.Observer, _ lifetime: Lifetime) {
        
    }
    
    func transferToCombineState(_ promise: @escaping Future<RType, HttpKit.HttpError>.Promise) {
        
    }
}
