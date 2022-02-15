//
//  HTTPAdapteeMocks.swift
//  HttpKitTests
//
//  Created by Andrei Ermoshin on 1/25/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
@testable import HttpKit
import Combine

final class MockedHTTPAdapteeWithFail<R, S, RX: RxInterface>: HTTPRxAdapter where RX.Observer.R == R, RX.S == S {
    typealias TYPE = R
    typealias SRV = S
    typealias RXI = RX
    
    var handlerType: HttpKit.ResponseHandlingApi<TYPE, SRV, RXI>
    
    init(_ handlerType: HttpKit.ResponseHandlingApi<TYPE, SRV, RXI>) {
        self.handlerType = handlerType
    }
    
    func performRequest(_ request: URLRequest, sucessCodes: [Int]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let nsError: NSError = .init(domain: "URLSession", code: 101, userInfo: nil)
            let result: Result<TYPE, HttpKit.HttpError> = .failure(.httpFailure(error: nsError))
            self?.wrapperHandler()(result)
        }
    }
    
    func wrapperHandler() -> (Result<TYPE, HttpKit.HttpError>) -> Void {
        let closure = { [weak self] (result: Result<TYPE, HttpKit.HttpError>) in
        }
        return closure
    }
    
    func transferToCombineState(_ promise: @escaping Future<TYPE, HttpKit.HttpError>.Promise,
                                _ endpoint: HttpKit.Endpoint<TYPE, SRV>) {
        
    }
}
