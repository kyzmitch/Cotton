//
//  AppCoordinator.swift
//  catowser
//
//  Created by Andrey Ermoshin on 13.11.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit

final class AppCoordinator<VCF: ViewControllerFactory>: Coordinator {
    let childCoordinators: [Coordinator]
    private let vcFactory: VCF
    private let windowRectangle: CGRect = {
        CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }()
    private let window: UIWindow
    
    init(_ vcFactory: VCF) {
        self.vcFactory = vcFactory
        childCoordinators = []
        window = UIWindow(frame: windowRectangle)
    }
    
    func start() {
        window.rootViewController = vcFactory.rootViewController
        window.makeKeyAndVisible()
    }
    
    func stop() {}
}
