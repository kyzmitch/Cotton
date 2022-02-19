//
//  DuckDuckGoServer.swift
//  BrowserNetworking
//
//  Created by Andrey Ermoshin on 19.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import HttpKit

public struct DuckDuckGoServer: ServerDescription {
    public var hostString: String {
        return domain
    }
    
    public let domain: String = "ac.duckduckgo.com"
    
    public init() {}
}
