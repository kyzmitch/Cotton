//
//  MainToolbarCoordinator.swift
//  catowser
//
//  Created by Andrey Ermoshin on 14.11.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit

final class MainToolbarCoordinator: Coordinator {
    let vcFactory: ViewControllerFactory
    var startedCoordinator: Coordinator?
    var parent: CoordinatorOwner?
    /// First of all, should be used to get access to child view controllers API
    private let presenter: AnyViewController
    private let tabsRenderer: TabRendererInterface
    private let downloadDelegate: DonwloadPanelDelegate
    private let settingsDelegate: GlobalMenuDelegate
    private let containerView: UIView
    
    init(_ vcFactory: ViewControllerFactory,
         _ presenter: AnyViewController,
         _ containerView: UIView,
         _ tabsRenderer: TabRendererInterface,
         _ downloadDelegate: DonwloadPanelDelegate,
         _ settingsDelegate: GlobalMenuDelegate) {
        self.vcFactory = vcFactory
        self.presenter = presenter
        self.tabsRenderer = tabsRenderer
        self.downloadDelegate = downloadDelegate
        self.settingsDelegate = settingsDelegate
        self.containerView = containerView
    }
    
    func start() {
        guard let vc = vcFactory.toolbarViewController(tabsRenderer, downloadDelegate, settingsDelegate) else {
            assertionFailure("Toolbar is only available on Phone layout")
            return
        }
        presenter.viewController.add(asChildViewController: vc, to: containerView)
    }
}
