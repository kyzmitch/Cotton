//
//  GoogleDnsServer.swift
//  HttpKit
//
//  Created by Andrei Ermoshin on 11/9/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import HttpKit

public struct GoogleDnsServer: ServerDescription {
    public var hostString: String {
        return domain
    }
    
    public let domain: String = "dns.google"
    
    public init() {}
}
