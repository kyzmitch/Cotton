//
//  HttpEnvironment.swift
//  catowser
//
//  Created by Andrei Ermoshin on 5/1/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import HttpKit
import BrowserNetworking
import Alamofire

final class HttpEnvironment {
    static let shared: HttpEnvironment = .init()
    
    let dnsClient: GoogleDnsClient
    let googleClient: GoogleSuggestionsClient
    
    private init() {
        let googleDNSserver = GoogleDnsServer()
        dnsClient = .init(server: googleDNSserver, jsonEncoder: JSONEncoding.default, httpTimeout: 2)
        let googleServer = GoogleServer()
        googleClient = .init(server: googleServer, jsonEncoder: JSONEncoding.default, httpTimeout: 10)
    }
}

extension HttpKit.Client where Server == GoogleDnsServer {
    static var shared: GoogleDnsClient {
        return HttpEnvironment.shared.dnsClient
    }
}

extension HttpKit.Client where Server == GoogleServer {
    static var shared: GoogleSuggestionsClient {
        return HttpEnvironment.shared.googleClient
    }
}
