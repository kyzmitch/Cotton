//
//  RootScreenCoordinator.swift
//  catowser
//
//  Created by Andrey Ermoshin on 13.11.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation

final class RootScreenCoordinator: Coordinator {
    enum Route {
        case searchSuggestions
        case tabPreviews
        case menu
    }
    
    let vcFactory: any ViewControllerFactory
    let childCoordinators: [any Coordinator]
    
    init(_ vcFactory: any ViewControllerFactory) {
        self.vcFactory = vcFactory
        self.childCoordinators = []
    }
    
    func start() {
        
    }
    
    func stop() {
        
    }
}
