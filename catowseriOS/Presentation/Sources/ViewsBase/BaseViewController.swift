//
//  BaseViewController.swift
//  catowser
//
//  Created by admin on 11/06/2017.
//  Copyright © 2017 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import UIKit

/// Base view controller
open class BaseViewController: UIViewController {}

extension UIViewController: UIIdiomable {}

extension UIView: UIIdiomable {}

/// UI idiomable interface
@MainActor public protocol UIIdiomable: AnyObject {
    /// Is tablet
    var isPad: Bool { get }
}

extension UIIdiomable {
    /// Is tablet
    public var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}
