//
//  NavigationActionableMocks.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 10/7/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CoreCatowser
import WebKit

class MockedNavAction: NavigationActionable {
    let navigationType: WKNavigationType
    let request: URLRequest
    
    init(_ url: URL, _ type: WKNavigationType) {
        request = URLRequest(url: url)
        navigationType = type
    }
}
