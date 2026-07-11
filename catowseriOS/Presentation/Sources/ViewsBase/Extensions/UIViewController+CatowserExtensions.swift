//
//  UIViewController+CatowserExtensions.swift
//  catowser
//
//  Created by Andrei Ermoshin on 21/02/2019.
//  Copyright © 2019 Cotton (former Catowser). All rights reserved.
//

import UIKit

extension UIViewController: SwiftUIPreviewable {
    /// Remove from child controller
    public func removeFromChild() {
        willMove(toParent: nil)
        removeFromParent()
        // remove view and constraints
        view.removeFromSuperview()
    }

    /// Add as a child controller to a container view
    ///
    /// - Parameter viewController: View controller to add
    /// - Parameter containerView: Container view where to add child view
    public func add(
        asChildViewController viewController: UIViewController,
        to containerView: UIView
    ) {
        // from docs `willMove` will be called automatically inside `addChild`
        addChild(viewController)
        // No need add constraints, they need to added specifically for each view
        // because view size can vary
        containerView.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
}

extension UIView: SwiftUIPreviewable {}

/// SwiftUI preview interface
public protocol SwiftUIPreviewable: AnyObject {
    /// Runtime check to determine if code was started by SwiftUI preview
    var isPreviewingSwiftUI: Bool { get }
}

extension SwiftUIPreviewable {
    /// Runtime check to determine if code was started by SwiftUI preview
    public var isPreviewingSwiftUI: Bool {
        // https://stackoverflow.com/a/61741858
        let value = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"]
        let correct = value == "1"
        return correct
    }
}
