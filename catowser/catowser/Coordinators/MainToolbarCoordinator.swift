//
//  MainToolbarCoordinator.swift
//  catowser
//
//  Created by Andrey Ermoshin on 14.11.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser

final class MainToolbarCoordinator: Coordinator {
    let vcFactory: ViewControllerFactory
    var startedCoordinator: Coordinator?
    weak var parent: CoordinatorOwner?
    var startedVC: AnyViewController?
    weak var presenterVC: AnyViewController?
    var navigationStack: UINavigationController?
    
    private weak var downloadDelegate: DownloadPanelPresenter?
    private weak var settingsDelegate: GlobalMenuDelegate?
    
    init(_ vcFactory: ViewControllerFactory,
         _ presenter: AnyViewController,
         _ downloadDelegate: DownloadPanelPresenter?,
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

extension MainToolbarCoordinator: CoordinatorOwner {
    func didFinish() {
        // Tabs view coordinator is stored as started
        startedCoordinator = nil
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

enum ToolbarPart: SubviewPart {}

extension MainToolbarCoordinator: Layouting {
    typealias SP = ToolbarPart
    
    func insertNext(_ subview: SP) {}
    
    func layout(_ step: OwnLayoutStep) {
        switch step {
        case .viewDidLoad(let topAnchor, _, _):
            viewDidLoad(topAnchor)
        default:
            break
        }
    }
    
    func layoutNext(_ step: LayoutStep<SP>) {
        
    }
}

private extension MainToolbarCoordinator {
    func viewDidLoad(_ topAnchor: NSLayoutYAxisAnchor?) {
        guard let toolbarView = startedVC?.controllerView else {
            return
        }
        guard let superView = presenterVC?.controllerView else {
            return
        }
        guard let topViewAnchor = topAnchor else {
            return
        }
        toolbarView.topAnchor.constraint(equalTo: topViewAnchor).isActive = true
        toolbarView.leadingAnchor.constraint(equalTo: superView.leadingAnchor).isActive = true
        toolbarView.trailingAnchor.constraint(equalTo: superView.trailingAnchor).isActive = true
        toolbarView.heightAnchor.constraint(equalToConstant: .tabBarHeight).isActive = true
        // Using superview's bottom here, but still on the upper level
        // we have to use a dummy view to fix a visual bug on Phone layout
        // for some iOS versions, toolbar buttons are fully visible
        // even with a dummy view
        if #available(iOS 11, *) {
            let bottomAnchor = superView.safeAreaLayoutGuide.bottomAnchor
            toolbarView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        } else {
            toolbarView.bottomAnchor.constraint(equalTo: superView.bottomAnchor).isActive = true
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
