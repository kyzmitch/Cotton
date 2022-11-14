//
//  Coordinator.swift
//  catowser
//
//  Created by Andrey Ermoshin on 12.11.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit

protocol Route {}

protocol Navigating: AnyObject {
    associatedtype R: Route
    func showNext(_ route: R)
}

protocol CoordinatorOwner: AnyObject {
    func didFinish()
}

protocol Coordinator: Navigating {
    var vcFactory: any ViewControllerFactory { get }
    /// For now it seems we could start only one child coordinator, no need to have an array of coordinators
    var startedCoordinator: (any Coordinator)? { get }
    /// Should be defined as weak reference for stop operation
    var parent: (any CoordinatorOwner)? { get }
    func start()
    func stop()
}

extension Coordinator {
    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    func stop() {
        parent?.didFinish()
    }
}
