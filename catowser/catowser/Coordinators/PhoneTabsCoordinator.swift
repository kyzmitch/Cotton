//
//  PhoneTabsCoordinator.swift
//  catowser
//
//  Created by Andrei Ermoshin on 11/15/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation

final class PhoneTabsCoordinator: Coordinator {
    let vcFactory: ViewControllerFactory
    var startedCoordinator: Coordinator?
    var parent: CoordinatorOwner?
    var startedVC: AnyViewController?
    var presenterVC: AnyViewController?
    
    init(_ vcFactory: ViewControllerFactory, _ presenter: AnyViewController) {
        self.vcFactory = vcFactory
        self.presenterVC = presenter
    }
    
    func start() {
        guard let vc = vcFactory.tabsPreviewsViewController(self) else {
            assertionFailure("Tabs previews screen is only for Phone layout")
            return
        }
        startedVC = vc
        presenterVC?.viewController.present(vc, animated: true, completion: nil)
    }
    
    func stop() {
        // tab select happens somehow before dismissing after selecting the tab
        // probably it also should be handled by coordinator
        startedVC?.viewController.dismiss(animated: true)
        startedCoordinator = nil
    }
}

enum TabsScreenRoute: Route {
}

extension PhoneTabsCoordinator: Navigating {
    typealias R = TabsScreenRoute
    
    func showNext(_ route: TabsScreenRoute) {
        
    }
}
