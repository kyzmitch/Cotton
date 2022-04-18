//
//  GoogleServer.swift
//  BrowserNetworking
//
//  Created by Andrei Ermoshin on 10/12/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import CoreHttpKit

public class GoogleServer: ServerDescription {
    public let scheme: HttpScheme = .https
    
    public var hostString: String {
        return "\(prefix).\(domain)"
    }
    
    public let domain: String = "google.com"
    
    private let prefix = "www"
}
