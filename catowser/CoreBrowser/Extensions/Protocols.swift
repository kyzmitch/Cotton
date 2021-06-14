//
//  Protocols.swift
//  catowser
//
//  Created by Andrei Ermoshin on 05/02/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit

/// Convinient protocol to be able to pass view controller
/// which confirms to some protocol
///
/// https://ilya.puchka.me/properties-of-types-conforming-to-protocols-in-swift/
public protocol AnyViewController: AnyObject {
    var viewController: UIViewController { get }
    var view: UIView { get }
}

public extension AnyViewController where Self: UIViewController {
    var viewController: UIViewController {
        return self
    }

    var view: UIView {
        return viewController.view
    }
}
