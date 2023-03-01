//
//  UIHostingController+Extension.swift
//  catowser
//
//  Created by Andrei Ermoshin on 5/27/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

#if canImport(SwiftUI)
import SwiftUI
#endif

@available(iOS 13.0, *)
extension UIHostingController where Content == BrowserMenuView {
    static func create(_ model: MenuViewModel) -> UIHostingController {
        let menuView = BrowserMenuView(model: model)
        return UIHostingController(rootView: menuView)
    }
}
