//
//  HttpEnvironment.swift
//  catowser
//
//  Created by Andrei Ermoshin on 5/1/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import HttpKit

extension HttpKit {
    final class Environment {
        static let shared: Environment = .init()
        
        let dnsClient: GoogleDnsClient
        let googleClient: GoogleSuggestionsClient
        
        private init() {
            let googleDNSserver = HttpKit.GoogleDnsServer()
            dnsClient = .init(server: googleDNSserver, httpTimeout: 2)
            let googleServer = HttpKit.GoogleServer()
            googleClient = .init(server: googleServer, httpTimeout: 10)
        }
    }
}

extension HttpKit.Client where Server == HttpKit.GoogleDnsServer {
    static var shared: GoogleDnsClient {
        return HttpKit.Environment.shared.dnsClient
    }
}

extension HttpKit.Client where Server == HttpKit.GoogleServer {
    static var shared: GoogleSuggestionsClient {
        return HttpKit.Environment.shared.googleClient
    }
}
