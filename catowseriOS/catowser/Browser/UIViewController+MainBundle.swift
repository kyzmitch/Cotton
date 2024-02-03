//
//  UIViewController+MainBundle.swift
//  catowser
//
//  Created by Andrei Ermoshin on 24/03/2019.
//  Copyright © 2019 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import UIKit

extension UIViewController {
    static func newFromNib() -> Self {
        let name = String(describing: self)
        let bundle = Bundle(for: self)
        let viewController = self.init(nibName: name, bundle: bundle)
        return viewController
    }

    static func newFromStoryboard() -> Self {
        let stName = String(describing: self.self)
        let identifier = String(describing: self.self)
        return instantiateFromStoryboard(stName, identifier: identifier)
    }

    static func instantiateFromStoryboard(_ storyboardName: String, identifier: String) -> Self {
        return instantiateFromStoryboardHelper(storyboardName, identifier: identifier)
    }
    
    fileprivate static func instantiateFromStoryboardHelper<T>(_ storyboardName: String, identifier: String) -> T {
        let currentBundle = Bundle(for: self)
        let storyboard = UIStoryboard(name: storyboardName, bundle: currentBundle)
        // swiftlint:disable:next force_cast
        let controller = storyboard.instantiateViewController(withIdentifier: identifier) as! T
        return controller
    }
}
