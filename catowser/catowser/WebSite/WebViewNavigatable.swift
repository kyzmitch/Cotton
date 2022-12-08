//
//  WebViewNavigatable.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/6/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import CoreHttpKit

protocol WebViewNavigatable: AnyObject {
    var canGoBack: Bool { get }
    var canGoForward: Bool { get }
    func goForward()
    func goBack()
    func reload()
    func enableJavaScript(_ enabled: Bool, for host: Host)
    
    var host: Host { get }
    var siteSettings: Site.Settings { get }
    var url: URL? { get }
}
