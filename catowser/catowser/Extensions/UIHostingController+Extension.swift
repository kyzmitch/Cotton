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
        let menuView = SiteMenuView().environmentObject(model)
        // Can't be compiled for some reason
        // the view is opaque type and controller expects specific
        // view type (SiteMenuView or Content).
        // The very weird thing is that it compiles
        // outside this extension.
        #if false
        return UIHostingController(rootView: menuView)
        #else
        return UIHostingController(rootView: SiteMenuView())
        #endif
    }
}

@available(iOS 13.0.0, *)
final class SiteMenuViewController: UIHostingController<SiteMenuView> {
    init(model: SiteMenuModel) {
        let viewWithModel = SiteMenuView()
        // The problem is that this doesn't allow to set model
        // using `environmentObject` because it returns opaque View type
        // and for some strange reason it doens't compile here
        super.init(rootView: viewWithModel)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}