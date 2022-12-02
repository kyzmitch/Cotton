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
    
    private weak var downloadDelegate: DonwloadPanelDelegate?
    private weak var settingsDelegate: GlobalMenuDelegate?
    
    init(_ vcFactory: ViewControllerFactory,
         _ presenter: AnyViewController,
         _ downloadDelegate: DonwloadPanelDelegate?,
         _ settingsDelegate: GlobalMenuDelegate) {
        self.vcFactory = vcFactory
        self.presenterVC = presenter
        self.downloadDelegate = downloadDelegate
        self.settingsDelegate = settingsDelegate
    }
    
    func start() {
        guard let vc = vcFactory.toolbarViewController(downloadDelegate, settingsDelegate, self) else {
            assertionFailure("Toolbar is only available on Phone layout")
            return
        }
        guard let containerView = presenterVC?.controllerView else {
            return
        }
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        startedVC = vc
        presenterVC?.viewController.add(asChildViewController: vc, to: containerView)
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

enum ToolbarPart: SubviewPart {
    case viewDidLoad(NSLayoutYAxisAnchor)
}

extension MainToolbarCoordinator: SubviewNavigation {
    typealias SP = ToolbarPart
    
    func insertNext(_ subview: SP) {
        switch subview {
        case .viewDidLoad(let topAnchor):
            viewDidLoad(topAnchor)
        }
    }
}

private extension MainToolbarCoordinator {
    func viewDidLoad(_ topAnchor: NSLayoutYAxisAnchor) {
        guard let toolbarView = startedVC?.controllerView else {
            return
        }
        guard let controllerView = presenterVC?.controllerView else {
            return
        }
        toolbarView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        toolbarView.leadingAnchor.constraint(equalTo: controllerView.leadingAnchor).isActive = true
        toolbarView.trailingAnchor.constraint(equalTo: controllerView.trailingAnchor).isActive = true
        toolbarView.heightAnchor.constraint(equalToConstant: .tabBarHeight).isActive = true
        if #available(iOS 11, *) {
            toolbarView.bottomAnchor.constraint(equalTo: controllerView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            toolbarView.bottomAnchor.constraint(equalTo: controllerView.bottomAnchor).isActive = true
        }
    }
    
    func showTabs() {
        // swiftlint:disable:next force_unwrapping
        let presenter = startedVC!
        let coordinator: PhoneTabsCoordinator = .init(vcFactory, presenter, self)
        coordinator.parent = self
        coordinator.start()
        startedCoordinator = coordinator
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
