//
//  HTTPVoidAdapter.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 2/10/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import ReactiveSwift
#if canImport(Combine)
import Combine
#endif


public protocol HTTPVoidAdapter: AnyObject {
    init(_ handlerType: ResponseVoidHandlingApi)
    func performVoidRequest(_ request: URLRequest,
                            sucessCodes: [Int])
    var wrapperHandler: ((Result<Void, HttpKit.HttpError>) -> Void) { get }
    var handlerType: ResponseVoidHandlingApi { get }
    
    /* mutating */ func transferToRxState(_ observer: Signal<Void, HttpKit.HttpError>.Observer, _ lifetime: Lifetime)
    /* mutating */ func transferToCombineState(_ promise: @escaping Future<Void, HttpKit.HttpError>.Promise)
}
