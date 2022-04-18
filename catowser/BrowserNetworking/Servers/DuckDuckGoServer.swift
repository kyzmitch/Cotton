//
//  DuckDuckGoServer.swift
//  BrowserNetworking
//
//  Created by Andrey Ermoshin on 19.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CoreHttpKit

public class DuckDuckGoServer: ServerDescription {
    public let scheme: HttpScheme = .https
    
    public var hostString: String {
        return domain
    }
    
    public let domain: String = "ac.duckduckgo.com"
}
