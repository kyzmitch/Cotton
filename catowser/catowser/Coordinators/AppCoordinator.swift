//
//  AppCoordinator.swift
//  catowser
//
//  Created by Andrey Ermoshin on 13.11.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit

enum MainScreenRoute: Route {
    case searchSuggestions
    case tabPreviews
    case menu(SiteMenuModel, UIView, CGRect)
}

enum MainScreenSubview: SubviewPart {
    case toolbar(UIView, TabRendererInterface, DonwloadPanelDelegate, GlobalMenuDelegate)
}

final class AppCoordinator: Coordinator, Navigating, SubviewNavigation, CoordinatorOwner {
    typealias R = MainScreenRoute
    typealias SP = MainScreenSubview
    
    var startedCoordinator: Coordinator?
    weak var parent: CoordinatorOwner?
    let vcFactory: ViewControllerFactory
    var startedVC: AnyViewController?
    var presenterVC: AnyViewController?
    
    /// Specific toolbar coordinator which should stay forever
    private var toolbarCoordinator: Coordinator?
    /// App window rectangle
    private let windowRectangle: CGRect = {
        CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }()
    /// main app window
    private let window: UIWindow
    
    init(_ vcFactory: ViewControllerFactory) {
        self.vcFactory = vcFactory
        window = UIWindow(frame: windowRectangle)
    }
    
    func start() {
        startedVC = vcFactory.rootViewController(self)
        window.rootViewController = startedVC?.viewController
        window.makeKeyAndVisible()
    }
    
    func showNext(_ route: R) {
        switch route {
        case .menu(let model, let sourceView, let sourceRect):
            startMenu(model, sourceView, sourceRect)
        case .searchSuggestions:
            startSearchSuggestions()
        case .tabPreviews:
            startTabPreviews()
        }
    }
    
    func insertNext(_ subview: SP) {
        switch subview {
        case .toolbar(let containerView, let tabRenderer, let downloadDelegate, let settingsDelegate):
            insertToolbar(containerView, tabRenderer, downloadDelegate, settingsDelegate)
        }
    }
}

private extension AppCoordinator {
    func startMenu(_ model: SiteMenuModel, _ sourceView: UIView, _ sourceRect: CGRect) {
        // swiftlint:disable:next force_unwrapping
        let presenter = startedVC!
        let coordinator: GlobalMenuCoordinator = .init(vcFactory,
                                                       presenter,
                                                       model,
                                                       sourceView,
                                                       sourceRect)
        coordinator.parent = self
        coordinator.start()
        startedCoordinator = coordinator
    }
    
    func startSearchSuggestions() {
        
    }
    
    func startTabPreviews() {
        
    }
    
    func insertToolbar(_ containerView: UIView,
                       _ tabRenderer: TabRendererInterface,
                       _ downloadDelegate: DonwloadPanelDelegate,
                       _ settingsDelegate: GlobalMenuDelegate) {
        // swiftlint:disable:next force_unwrapping
        let presenter = startedVC!
        let coordinator: MainToolbarCoordinator = .init(vcFactory,
                                                        presenter,
                                                        containerView,
                                                        tabRenderer,
                                                        downloadDelegate,
                                                        settingsDelegate)
        coordinator.parent = self
        coordinator.start()
        toolbarCoordinator = coordinator
    }
}

// MARK: - Temporarily methods which MUST be refactored

extension AppCoordinator {
    var toolbarView: UIView? {
        toolbarCoordinator?.startedVC?.controllerView
    }
    
    var toolbarViewController: AnyViewController? {
        toolbarCoordinator?.startedVC
    }
}
