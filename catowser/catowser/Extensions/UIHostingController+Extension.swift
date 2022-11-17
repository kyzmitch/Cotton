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
    static func create(_ model: SiteMenuModel) -> UIHostingController {
        let menuView = SiteMenuView(model: model)
        return UIHostingController(rootView: menuView)
    }
}

@available(iOS 13.0.0, *)
final class SiteMenuViewController<C: Navigating>: UIHostingController<SiteMenuView> where C.R == MenuScreenRoute {
    private weak var coordinator: C?
    
    init(_ model: SiteMenuModel, _ coordinator: C) {
        self.coordinator = coordinator
        let view = SiteMenuView(model: model)
        super.init(rootView: view)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        coordinator?.stop()
    }
}
