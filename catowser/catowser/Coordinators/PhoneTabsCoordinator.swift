//
//  PhoneTabsCoordinator.swift
//  catowser
//
//  Created by Andrei Ermoshin on 11/15/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser

protocol PhoneTabsDelegate: AnyObject {
    func didTabSelect(_ tab: Tab)
    func didTabAdd()
}

final class PhoneTabsCoordinator: Coordinator {
    let vcFactory: any ViewControllerFactory
    var startedCoordinator: Coordinator?
    weak var parent: CoordinatorOwner?
    var startedVC: AnyViewController?
    weak var presenterVC: AnyViewController?
    var navigationStack: UINavigationController?
    
    private weak var delegate: PhoneTabsDelegate?
    
    init(_ vcFactory: any ViewControllerFactory,
         _ presenter: AnyViewController,
         _ delegate: PhoneTabsDelegate) {
        self.vcFactory = vcFactory
        self.presenterVC = presenter
        self.delegate = delegate
    }
    
    func start() {
        guard let vc = vcFactory.tabsPreviewsViewController(self) else {
            assertionFailure("Tabs previews screen is only for Phone layout")
            return
        }
        startedVC = vc
        presenterVC?.viewController.present(vc, animated: true, completion: nil)
    }
}

enum TabsScreenRoute: Route {
    case error
    case selectTab(Tab)
    case addTab
}

extension PhoneTabsCoordinator: Navigating {
    
    typealias R = TabsScreenRoute
    
    func showNext(_ route: TabsScreenRoute) {
        switch route {
        case .selectTab(let contentType):
            showSelected(contentType)
        case .addTab:
            showAdded()
        case .error:
            showError()
        }
    }
    
    func stop() {
        startedVC?.viewController.dismiss(animated: true)
        parent?.coordinatorDidFinish(self)
    }
}

private extension PhoneTabsCoordinator {
    func showSelected(_ tab: Tab) {
        delegate?.didTabSelect(tab)
    }
    
    func showAdded() {
        delegate?.didTabAdd()
    }
    
    func showError() {
        guard let vc = vcFactory.tabsPreviewsViewController(self) else {
            assertionFailure("Tabs previews screen is only for Phone layout")
            return
        }
        AlertPresenter.present(on: vc)
    }
}
