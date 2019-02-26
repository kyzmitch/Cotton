//
//  BaseViewController.swift
//  catowser
//
//  Created by admin on 11/06/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

}

extension UIViewController {
    func add(asChildViewController viewController: UIViewController, to containerView: UIView) {
        // from docs `willMove` will be called automatically inside `addChild`
        addChild(viewController)
        // No need add constraints, they need to added specifically for each view
        // because view size can vary
        containerView.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
}
