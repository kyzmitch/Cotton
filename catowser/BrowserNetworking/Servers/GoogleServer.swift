//
//  GoogleServer.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 10/12/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import HttpKit

public struct GoogleServer: ServerDescription {
    public var hostString: String {
        return "\(prefix).\(domain)"
    }
    
    public let domain: String = "google.com"
    
    private let prefix = "www"
    
    public init() {}
}
