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
extension UIHostingController where Content == SiteMenuView {
    static func create(siteMenu model: SiteMenuModel) -> UIHostingController {
        let menuView = SiteMenuView(model: model)
        return UIHostingController(rootView: menuView)
    }
}

@available(iOS 13.0.0, *)
final class SiteMenuViewController: UIHostingController<SiteMenuView> {
    init(model: SiteMenuModel) {
        let viewWithModel = SiteMenuView(model: model)
        super.init(rootView: viewWithModel)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
