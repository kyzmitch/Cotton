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

final class AppCoordinator: Coordinator {
    typealias R = MainScreenRoute
    var startedCoordinator: (any Coordinator)?
    weak var parent: CoordinatorOwner?
    let vcFactory: any ViewControllerFactory
    private let windowRectangle: CGRect = {
        CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }()
    private let window: UIWindow
    /// This will protect from showing next screens when this coordinator is not started
    private var rootViewController: UIViewController!
    
    init(_ vcFactory: any ViewControllerFactory) {
        self.vcFactory = vcFactory
        window = UIWindow(frame: windowRectangle)
    }
    
    func start() {
        rootViewController = vcFactory.rootViewController(self)
        window.rootViewController = rootViewController
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
}

extension AppCoordinator: CoordinatorOwner {
    func didFinish() {
        // removes previously started coordinator
        startedCoordinator = nil
    }
}

private extension AppCoordinator {
    func startMenu(_ model: SiteMenuModel, _ sourceView: UIView, _ sourceRect: CGRect) {
        let coordinator: GlobalMenuCoordinator = .init(vcFactory,
                                                       rootViewController,
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
}
