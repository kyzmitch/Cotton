//
//  UIViewController+CatowserExtensions.swift
//  catowser
//
//  Created by Andrei Ermoshin on 21/02/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit

public extension UIViewController {
    func removeFromChild() {
        willMove(toParent: nil)
        removeFromParent()
        // remove view and constraints
        view.removeFromSuperview()
    }
}
