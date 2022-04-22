//
//  DuckDuckGoServer.swift
//  BrowserNetworking
//
//  Created by Andrey Ermoshin on 19.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CoreHttpKit

public class DuckDuckGoServer: ServerDescription {
    public override var hostString: String {
        return domain
    }
    
    public override var domain: String {
        return "ac.duckduckgo.com"
    }
    
    public override init() {}
}
