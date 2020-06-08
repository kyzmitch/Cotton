//
//  HTMLContentMessage.swift
//  JSPlugins
//
//  Created by Andrei Ermoshin on 6/8/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import Foundation
import HttpKit
import SwiftSoup

struct HTMLContentMessage: Decodable {
    let hostname: HttpKit.Host
    let html: Document
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let hostnameString = try container.decode(String.self, forKey: .hostname)
        guard let kitHost = HttpKit.Host(rawValue: hostnameString) else {
            throw CottonError.parseHost
        }
        hostname = kitHost
        let htmlString = try container.decode(String.self, forKey: .htmlString)
        html = try SwiftSoup.parse(htmlString)
    }
    
    private enum CodingKeys: String, CodingKey {
        case hostname
        case htmlString
    }
}
