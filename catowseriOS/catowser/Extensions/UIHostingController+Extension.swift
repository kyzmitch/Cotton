//
//  UIHostingController+Extension.swift
//  catowser
//
//  Created by Andrei Ermoshin on 5/27/20.
//  Copyright © 2020 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import SwiftUI

extension UIHostingController where Content == BrowserMenuView {
    static func create(_ model: MenuViewModel) -> UIHostingController {
        let menuView = BrowserMenuView(model)
        return UIHostingController(rootView: menuView)
    }
}
