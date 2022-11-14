//
//  Coordinator.swift
//  catowser
//
//  Created by Andrey Ermoshin on 12.11.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit

protocol Route {}
protocol SubviewPart {}

protocol Navigating: AnyObject {
    associatedtype R: Route
    func showNext(_ route: R)
}

protocol SubviewNavigation: AnyObject {
    associatedtype SP: SubviewPart
    func insertNext(_ subview: SP)
}

protocol CoordinatorOwner: AnyObject {
    func didFinish()
}

protocol Coordinator: AnyObject {
    var vcFactory: ViewControllerFactory { get }
    /// For now it seems we could start only one child coordinator, no need to have an array of coordinators
    var startedCoordinator: Coordinator? { get }
    /// Should be defined as weak reference for stop operation
    var parent: CoordinatorOwner? { get }
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
