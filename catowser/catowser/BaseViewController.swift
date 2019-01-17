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
        viewController.willMove(toParent: self)
        addChild(viewController)
        containerView.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
}
