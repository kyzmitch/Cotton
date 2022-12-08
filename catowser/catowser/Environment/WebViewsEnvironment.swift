//
//  WebViewsEnvironment.swift
//  catowser
//
//  Created by Andrei Ermoshin on 11/21/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit

final class WebViewsEnvironment {
    static let shared: WebViewsEnvironment = .init()
    
    let reuseManager: WebViewsReuseManager
    let viewControllerFactory: ViewControllerFactory
    
    private init() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            viewControllerFactory = TabletViewControllerFactory()
        } else {
            viewControllerFactory = PhoneViewControllerFactory()
        }
        reuseManager = .init(viewControllerFactory)
    }
}

extension WebViewsReuseManager {
    static var shared: WebViewsReuseManager {
        return WebViewsEnvironment.shared.reuseManager
    }
}

extension ViewControllerFactory {
    static var shared: any ViewControllerFactory {
        return WebViewsEnvironment.shared.viewControllerFactory
    }
}
