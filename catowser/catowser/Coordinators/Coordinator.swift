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
    var vcFactory: any ViewControllerFactory { get }
    func showNext(_ route: R)
    func stop()
    
    // TODO: remove temporary method
    var toolbarView: UIView? { get }
    // TODO: remove temporary reference property
    var layoutCoordinator: AppLayoutCoordinator? { get }
}

// TODO: remove temporary extension
extension Navigating {
    var toolbarView: UIView? {
        return nil
    }
    
    var layoutCoordinator: AppLayoutCoordinator? {
        return nil
    }
}

protocol SubviewNavigation: AnyObject {
    associatedtype SP: SubviewPart
    func insertNext(_ subview: SP)
}

protocol CoordinatorOwner: AnyObject {
    func didFinish()
}

protocol Coordinator: AnyObject {
    /// For now it seems we could start only one child coordinator, no need to have an array of coordinators
    var startedCoordinator: Coordinator? { get set }
    /// Should be defined as weak reference for stop operation
    var parent: CoordinatorOwner? { get }
    /// Started/created view controller during coordinator start. It is optional because `start` is called after `init`
    var startedVC: AnyViewController? { get }
    /// View controller used to present/show this Coordinator's started vc
    var presenterVC: AnyViewController? { get }
    
    func start()
}

extension Coordinator {
    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}

extension Coordinator where Self: Navigating {
    func stop() {
        parent?.didFinish()
    }
}

extension CoordinatorOwner where Self: Coordinator {
    func didFinish() {
        // removes previously started coordinator
        startedCoordinator = nil
    }
}
