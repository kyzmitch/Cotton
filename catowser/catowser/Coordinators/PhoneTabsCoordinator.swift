//
//  PhoneTabsCoordinator.swift
//  catowser
//
//  Created by Andrei Ermoshin on 11/15/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import CoreBrowser

protocol PhoneTabsDelegate: AnyObject {
    func didTabSelect(_ tab: Tab)
    func didTabAdd()
}

final class PhoneTabsCoordinator: Coordinator {
    let vcFactory: ViewControllerFactory
    var startedCoordinator: Coordinator?
    var parent: CoordinatorOwner?
    var startedVC: AnyViewController?
    var presenterVC: AnyViewController?
    
    private weak var delegate: PhoneTabsDelegate?
    
    init(_ vcFactory: ViewControllerFactory,
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
}

private extension PhoneTabsCoordinator {
    func showSelected(_ tab: Tab) {
        startedVC?.viewController.dismiss(animated: true)
        startedCoordinator = nil
        
        delegate?.didTabSelect(tab)
    }
    
    func showAdded() {
        delegate?.didTabAdd()
        // on previews screen will make new added tab always selected
        // same behaviour has Safari and Firefox
        if DefaultTabProvider.shared.selected {
            startedVC?.viewController.dismiss(animated: true)
            startedCoordinator = nil
        }
    }
    
    func showError() {
        guard let vc = vcFactory.tabsPreviewsViewController(self) else {
            assertionFailure("Tabs previews screen is only for Phone layout")
            return
        }
        AlertPresenter.present(on: vc)
    }
}
