//
//  SiteMenuViewController.swift
//  catowser
//
//  Created by Andrey Ermoshin on 10.12.2022.
//  Copyright © 2022 Cotton (former Catowser). All rights reserved.
//

import UIKit
import SwiftUI

@available(iOS 13.0.0, *)
final class SiteMenuViewController<C: Navigating>: UIHostingController<BrowserMenuView> where C.R == MenuScreenRoute {
    private weak var coordinator: C?

    init(_ model: MenuViewModel, _ coordinator: C) {
        self.coordinator = coordinator
        let view = BrowserMenuView(model)
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
