//
//  URLData.swift
//  catowser
//
//  Created by Andrei Ermoshin on 8/6/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import CoreHttpKit

enum URLData {
    case url(URL)
    case info(URLInfo)
    
    func updateWith(ip: String) -> URLInfo? {
        switch self {
        case .url(let uRL):
            return URLInfo(uRL)?.withIPAddress(ipAddress: ip)
        case .info(let uRLInfo):
            return uRLInfo.withIPAddress(ipAddress: ip)
        }
    }
    
    var platformURL: URL {
        switch self {
        case .url(let uRL):
            return uRL
        case .info(let uRLInfo):
            return uRLInfo.platformURL
        }
    }
    
    var host: Host? {
        switch self {
        case .url(let uRL):
            return uRL.kitHost
        case .info(let uRLInfo):
            return uRLInfo.host()
        }
    }
    
    var hasIPHost: Bool {
        switch self {
        case .url(let uRL):
            return uRL.hasIPHost
        case .info(let uRLInfo):
            // TODO: double check that platform URL is needed value here
            return uRLInfo.platformURL.hasIPHost
        }
    }
}
