//
//  UIViewController+CatowserExtensions.swift
//  catowser
//
//  Created by Andrei Ermoshin on 21/02/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit

extension UIViewController {
    func removeFromChild() {
        willMove(toParent: nil)
        removeFromParent()
        // remove view and constraints
        view.removeFromSuperview()
    }

    func add(asChildViewController viewController: UIViewController, to containerView: UIView) {
        // from docs `willMove` will be called automatically inside `addChild`
        addChild(viewController)
        // No need add constraints, they need to added specifically for each view
        // because view size can vary
        containerView.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
}
