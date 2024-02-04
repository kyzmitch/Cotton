//
//  ViewsEnvironment.swift
//  catowser
//
//  Created by Andrei Ermoshin on 11/21/22.
//  Copyright © 2022 Cotton (former Catowser). All rights reserved.
//

import UIKit

@MainActor
final class ViewsEnvironment {
    static let shared: ViewsEnvironment = .init()

    let reuseManager: WebViewsReuseManager
    let vcFactory: ViewControllerFactory

    private init() {
        // Could read global state to inject current UIFrameworkType value right away,
        // and it will make init block this init, probably not good idea
        if UIDevice.current.userInterfaceIdiom == .pad {
            vcFactory = TabletViewControllerFactory()
        } else {
            vcFactory = PhoneViewControllerFactory()
        }
        reuseManager = .init(vcFactory)
    }
}

extension WebViewsReuseManager {
    static var shared: WebViewsReuseManager {
        return ViewsEnvironment.shared.reuseManager
    }
}
