//
//  AnyViewController.swift
//  catowser
//
//  Created by Andrei Ermoshin on 05/02/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import SwiftUI

/// Convinient protocol to be able to pass view controller
/// which confirms to some protocol
///
/// https://ilya.puchka.me/properties-of-types-conforming-to-protocols-in-swift/
@MainActor
protocol AnyViewController: AnyObject {
    var viewController: UIViewController { get }
    var controllerView: UIView { get }
}

extension UIViewController: AnyViewController {
    var controllerView: UIView {
        self.view
    }
    
    var viewController: UIViewController {
        return self
    }
}
