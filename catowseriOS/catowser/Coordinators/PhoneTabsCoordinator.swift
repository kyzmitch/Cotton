//
//  PhoneTabsCoordinator.swift
//  catowser
//
//  Created by Andrei Ermoshin on 11/15/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import UIKit
import CoreBrowser
import FeaturesFlagsKit

protocol PhoneTabsDelegate: AnyObject {
    func didTabSelect(_ tab: Tab) async
    func didTabAdd() async
}

final class PhoneTabsCoordinator: Coordinator {
    let vcFactory: any ViewControllerFactory
    var startedCoordinator: Coordinator?
    weak var parent: CoordinatorOwner?
    var startedVC: AnyViewController?
    weak var presenterVC: AnyViewController?
    var navigationStack: UINavigationController?
    
    private weak var delegate: PhoneTabsDelegate?
    let uiFramework: UIFrameworkType
    
    init(_ vcFactory: any ViewControllerFactory,
         _ presenter: AnyViewController?,
         _ delegate: PhoneTabsDelegate,
         _ uiFramework: UIFrameworkType) {
        self.vcFactory = vcFactory
        self.presenterVC = presenter
        self.delegate = delegate
        self.uiFramework = uiFramework
    }
    
    func start() {
        Task {
            let vm = await ViewModelFactory.shared.tabsPreviewsViewModel()
            guard let vc = vcFactory.tabsPreviewsViewController(self, vm) else {
                assertionFailure("Tabs previews screen is only for Phone layout")
                return
            }
            startedVC = vc
            guard !uiFramework.isUIKitFree else {
                // For SwiftUI mode we still need to create view controller
                // but presenting should happen on SwiftUI level
                return
            }
            presenterVC?.viewController.present(vc, animated: true, completion: nil)
        }
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
        guard !uiFramework.isUIKitFree else {
            // Need to try to save coordinator for SwiftUI mode
            // because it was started at App start and not when
            // user presses on tab previews button in toolbar
            // as it is done in UIKit mode
            return
        }
        parent?.coordinatorDidFinish(self)
    }
}

private extension PhoneTabsCoordinator {
    func showSelected(_ tab: Tab) {
        Task {
            await delegate?.didTabSelect(tab)
        }
    }
    
    func showAdded() {
        Task {
            await delegate?.didTabAdd()
        }
    }
    
    func showError() {
        Task {
            let vm = await ViewModelFactory.shared.tabsPreviewsViewModel()
            guard let vc = vcFactory.tabsPreviewsViewController(self, vm) else {
                assertionFailure("Tabs previews screen is only for Phone layout")
                return
            }
            AlertPresenter.present(on: vc)
        }
    }
}
