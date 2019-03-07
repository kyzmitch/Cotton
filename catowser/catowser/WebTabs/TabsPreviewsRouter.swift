//
//  TabsPreviewsRouter.swift
//  catowser
//
//  Created by Andrei Ermoshin on 05/02/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser

final class TabsPreviewsRouter {
    
    private weak var presenter: TabRendererInterface?
    private var animated: Bool

    init(presenter: TabRendererInterface, animated: Bool = true) {
        self.presenter = presenter
        self.animated = animated
    }

    /// Asks presenter to open specific tab in web view
    func dismiss(andLoad tabContent: Tab.ContentType) {
        presenter?.viewController.dismiss(animated: false, completion: { [weak self] in
            self?.presenter?.open(tabContent: tabContent)
        })
    }
}
