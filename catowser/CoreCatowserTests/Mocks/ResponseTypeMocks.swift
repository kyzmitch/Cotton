//
//  ResponseTypeMocks.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 10/4/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import HttpKit

public final class MockedDNSResponse: ResponseType {
    static public var successCodes: [Int] {
        [200]
    }
    
    public let queryText: String
    public let textResults: [String]
    
    public init(_ text: String, _ results: [String]) {
        queryText = text
        textResults = results
    }
}
