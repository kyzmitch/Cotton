//
//  MainToolbarCoordinator.swift
//  catowser
//
//  Created by Andrey Ermoshin on 14.11.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser

final class MainToolbarCoordinator: Coordinator, CoordinatorOwner {
    let vcFactory: ViewControllerFactory
    var startedCoordinator: Coordinator?
    var parent: CoordinatorOwner?
    var startedVC: AnyViewController?
    var presenterVC: AnyViewController?
    
    private let downloadDelegate: DonwloadPanelDelegate
    private let settingsDelegate: GlobalMenuDelegate
    private let containerView: UIView
    
    init(_ vcFactory: ViewControllerFactory,
         _ presenter: AnyViewController,
         _ containerView: UIView,
         _ downloadDelegate: DonwloadPanelDelegate,
         _ settingsDelegate: GlobalMenuDelegate) {
        self.vcFactory = vcFactory
        self.presenterVC = presenter
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
}

private extension MainToolbarCoordinator {
    func showTabs() {
        // swiftlint:disable:next force_unwrapping
        let presenter = startedVC!
        let coordinator: PhoneTabsCoordinator = .init(vcFactory, presenter, self)
        coordinator.parent = self
        coordinator.start()
        startedCoordinator = coordinator
    }
}

enum ToolbarRoute: Route {
    case tabs
}

extension MainToolbarCoordinator: Navigating {
    typealias R = ToolbarRoute
    
    func showNext(_ route: R) {
        switch route {
        case .tabs:
            showTabs()
        }
    }
}

extension MainToolbarCoordinator: PhoneTabsDelegate {
    func didTabSelect(_ tab: CoreBrowser.Tab) {
        TabsListManager.shared.select(tab: tab)
    }
    
    func didTabAdd() {
        let tab = Tab(contentType: DefaultTabProvider.shared.contentState)
        // newly added tab moves selection to itself
        // so, it is opened by manager by default
        // but user maybe don't want to move that tab right away
        TabsListManager.shared.add(tab: tab)
    }
}
