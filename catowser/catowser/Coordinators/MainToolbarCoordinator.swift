//
//  MainToolbarCoordinator.swift
//  catowser
//
//  Created by Andrey Ermoshin on 14.11.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit

enum ToolbarRoute: Route {
    case tabs
}

final class MainToolbarCoordinator: Coordinator, Navigating, CoordinatorOwner {
    typealias R = ToolbarRoute
    let vcFactory: ViewControllerFactory
    var startedCoordinator: Coordinator?
    var parent: CoordinatorOwner?
    var startedVC: AnyViewController?
    var presenterVC: AnyViewController?
    
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
        self.presenterVC = presenter
        self.tabsRenderer = tabsRenderer
        self.downloadDelegate = downloadDelegate
        self.settingsDelegate = settingsDelegate
        self.containerView = containerView
    }
    
    func start() {
        guard let vc = vcFactory.toolbarViewController(downloadDelegate, settingsDelegate, self) else {
            assertionFailure("Toolbar is only available on Phone layout")
            return
        }
        startedVC = vc
        presenterVC?.viewController.add(asChildViewController: vc, to: containerView)
    }
    
    func showNext(_ route: R) {
        switch route {
        case .tabs:
            showTabs()
        }
    }
}

private extension MainToolbarCoordinator {
    func showTabs() {
        // swiftlint:disable:next force_unwrapping
        let presenter = startedVC!
        let coordinator: PhoneTabsCoordinator = .init(vcFactory, presenter)
        coordinator.parent = self
        coordinator.start()
        startedCoordinator = coordinator
    }
}
