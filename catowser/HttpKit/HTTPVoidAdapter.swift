//
//  HTTPVoidAdapter.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 2/10/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

#if canImport(Combine)
import Combine
#endif

public protocol HTTPVoidAdapter: AnyObject {
    associatedtype SRV
    associatedtype RXI: RxVoidInterface where RXI.S == SRV
    
    var handlerType: HttpKit.ResponseVoidHandlingApi<SRV, RXI> { get set }
    
    init(_ handlerType: HttpKit.ResponseVoidHandlingApi<SRV, RXI>)
    func performVoidRequest(_ request: URLRequest,
                            sucessCodes: [Int])
    
    /// This is not defined in ResponseHandlingApi because it is a value type and this function should capture self
    /// So, better to store it here in reference type
    func wrapperHandler() -> (Result<Void, HttpKit.HttpError>) -> Void
    
    /* mutating */ func transferToCombineState(_ promise: @escaping Future<Void, HttpKit.HttpError>.Promise,
                                               _ endpoint: HttpKit.VoidEndpoint<SRV>)
}
