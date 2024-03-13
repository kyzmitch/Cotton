//
//  DuckDuckGoServer.swift
//  BrowserNetworking
//
//  Created by Andrey Ermoshin on 19.02.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CottonCoreBaseKit

public class DuckDuckGoServer: ServerDescription {
    public convenience init() {
        // swiftlint:disable:next force_try
        let host = try! Host(input: "ac.duckduckgo.com")
        self.init(host: host, scheme: .https)
    }
}
