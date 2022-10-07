//
//  NavigationActionableMocks.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 10/7/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CoreCatowser
import WebKit

class MockedOtherNavAction: NavigationActionable {
    let navigationType: WKNavigationType = .other
    let request: URLRequest
    
    init(_ url: URL) {
        request = URLRequest(url: url)
    }
}

class MockedLinkActivationNavAction: NavigationActionable {
    let navigationType: WKNavigationType = .linkActivated
    let request: URLRequest
    
    init(_ url: URL) {
        request = URLRequest(url: url)
    }
}
