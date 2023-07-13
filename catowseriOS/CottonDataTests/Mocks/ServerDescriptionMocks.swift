//
//  ServerDescriptionMocks.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 10/4/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CottonBase

final class MockedGoodDnsServer: ServerDescription {
    convenience init() {
        // swiftlint:disable:next force_try
        let host = try! Host(input: "www.example.com")
        self.init(host: host, scheme: .https)
    }
}
