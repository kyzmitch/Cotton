//
//  GoogleServer.swift
//  BrowserNetworking
//
//  Created by Andrei Ermoshin on 10/12/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import CoreHttpKit

public class GoogleServer: ServerDescription {
    public convenience init() {
        // swiftlint:disable:next force_try
        let host = try! Host(input: "www.google.com")
        self.init(host: host, scheme: .https)
    }
}
