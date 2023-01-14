//
//  ViewsEnvironment.swift
//  catowser
//
//  Created by Andrei Ermoshin on 11/21/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit

final class ViewsEnvironment {
    static let shared: ViewsEnvironment = .init()
    
    let reuseManager: WebViewsReuseManager
    let vcFactory: ViewControllerFactory
    
    private init() {
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
