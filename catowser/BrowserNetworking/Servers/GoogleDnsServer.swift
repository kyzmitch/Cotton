//
//  GoogleDnsServer.swift
//  BrowserNetworking
//
//  Created by Andrei Ermoshin on 11/9/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import CoreHttpKit

public class GoogleDnsServer: ServerDescription {
    public let scheme: HttpScheme = .https
    
    public var hostString: String {
        return domain
    }
    
    public let domain: String = "dns.google"
}
