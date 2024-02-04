//
//  Coordinator.swift
//  catowser
//
//  Created by Andrey Ermoshin on 12.11.2022.
//  Copyright © 2022 Cotton (former Catowser). All rights reserved.
//

import UIKit

@MainActor
protocol Coordinator: AnyObject {
    /// For now it seems we could start only one child coordinator, no need to have an array of coordinators,
    /// but it only applies to navigation related routes (presented or pushed to navigation stack)
    /// and not to subview layout navigation.
    var startedCoordinator: Coordinator? { get set }
    /// Should be defined as weak reference for `stop` operation
    var parent: CoordinatorOwner? { get }
    /// Started/created view controller during coordinator `start`.
    /// It is optional because `start` is called after `init`
    var startedVC: AnyViewController? { get }
    /// View controller used to present/show this Coordinator's started vc
    var presenterVC: AnyViewController? { get }
    /// Navigation stack
    var navigationStack: UINavigationController? { get }

    func start()
}

@MainActor
protocol CoordinatorOwner: AnyObject {
    /// Usually should be called in `stop` function of a `Navigating` impl.
    /// Default implementation should remove started coordinator reference.
    func coordinatorDidFinish(_ coordinator: Coordinator)
}

extension Coordinator {
    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}

protocol Route {}
protocol SubviewPart {}

@MainActor
protocol Navigating: AnyObject {
    associatedtype R: Route
    var vcFactory: any ViewControllerFactory { get }
    func showNext(_ route: R)
    /// Optional method needed for SwiftUI to be able to pass presenter if it is not available right away
    func showNext(_ route: R, _ presenter: AnyViewController?)
    func stop()
}

extension Navigating {
    /* optional */ func showNext(_ route: R, _ presenter: AnyViewController?) {}
}

enum LayoutStep<SP: SubviewPart> {
    case viewDidLoad(SP, NSLayoutYAxisAnchor? = nil, NSLayoutYAxisAnchor? = nil, CGFloat? = nil)
    /// SP - subview type, optional CGFloat to pass container height
    case viewDidLayoutSubviews(SP, CGFloat? = nil)
    case viewSafeAreaInsetsDidChange(SP)
}

enum OwnLayoutStep {
    /// top and bottom anchors if needed, toolbar height if needed
    case viewDidLoad(NSLayoutYAxisAnchor? = nil, NSLayoutYAxisAnchor? = nil, CGFloat? = nil)
    /// optional CGFloat to be able to pass container height
    case viewDidLayoutSubviews(CGFloat? = nil)
    case viewSafeAreaInsetsDidChange
}

@MainActor
protocol Layouting: AnyObject {
    associatedtype SP: SubviewPart

    /// Inserted started view, could be redefined when there is no view controller for coordinator
    var startedView: UIView? { get }

    func insertNext(_ subview: SP)
    func layout(_ step: OwnLayoutStep)
    func layoutNext(_ step: LayoutStep<SP>)
}

extension Coordinator where Self: Navigating {
    func stop() {
        parent?.coordinatorDidFinish(self)
    }
}

extension Coordinator where Self: Layouting {
    var startedView: UIView? {
        startedVC?.controllerView
    }
}

extension CoordinatorOwner where Self: Coordinator {
    func coordinatorDidFinish(_ coordinator: Coordinator) {
        if coordinator === startedCoordinator {
            // removes previously started coordinator
            startedCoordinator = nil
        }
    }
}
