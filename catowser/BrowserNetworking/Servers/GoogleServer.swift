//
//  GoogleServer.swift
//  BrowserNetworking
//
//  Created by Andrei Ermoshin on 10/12/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import CoreHttpKit

public class GoogleServer: ServerDescription {
    public override var hostString: String {
        return "\(prefix).\(domain)"
    }
    
    public override var domain: String {
        return "google.com"
    }
    
    private let prefix = "www"
    
    public override init() {}
}
