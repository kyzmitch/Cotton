//
//  ToolbarRouter.swift
//  catowser
//
//  Created by Andrei Ermoshin on 28/01/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser

final class ToolbarRouter {
    private var animated: Bool
    private weak var presenter: AnyViewController?

    private var vc: UIViewController? {
        return presenter?.viewController
    }

    private let tabsPreviewsRouter: TabsPreviewsRouter

    init(presenter: TabRendererInterface, animated: Bool = true) {
        self.presenter = presenter
        self.animated = animated
        tabsPreviewsRouter = TabsPreviewsRouter(presenter: presenter)
    }

    func showTabs() {
        let tabsVc = TabsPreviewsViewController(router: tabsPreviewsRouter)
        vc?.present(tabsVc, animated: animated, completion: nil)
    }
}
