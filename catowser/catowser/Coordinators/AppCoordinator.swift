//
//  AppCoordinator.swift
//  catowser
//
//  Created by Andrey Ermoshin on 13.11.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit

final class AppCoordinator: Coordinator {
    var childCoordinators: [any Coordinator]
    let vcFactory: any ViewControllerFactory
    private let windowRectangle: CGRect = {
        CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }()
    private let window: UIWindow
    
    init(_ vcFactory: any ViewControllerFactory) {
        self.vcFactory = vcFactory
        childCoordinators = []
        window = UIWindow(frame: windowRectangle)
    }
    
    func start() {
        let nextCoordinator = RootScreenCoordinator(vcFactory)
        childCoordinators.append(nextCoordinator)
        window.rootViewController = vcFactory.rootViewController(nextCoordinator)
        window.makeKeyAndVisible()
    }
    
    func stop() {}
}
