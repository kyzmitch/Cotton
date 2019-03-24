//
//  UIViewController+MainBundle.swift
//  catowser
//
//  Created by Andrei Ermoshin on 24/03/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit

extension UIViewController {
    class func instantiateFromStoryboard(_ storyboardName: String, identifier: String) -> Self {
        return instantiateFromStoryboardHelper(storyboardName, identifier: identifier)
    }
    
    fileprivate class func instantiateFromStoryboardHelper<T>(_ storyboardName: String, identifier: String) -> T {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle(for: self))
        let controller = storyboard.instantiateViewController(withIdentifier: identifier) as! T
        return controller
    }
}
