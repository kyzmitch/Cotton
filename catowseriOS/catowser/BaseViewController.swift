//
//  BaseViewController.swift
//  catowser
//
//  Created by admin on 11/06/2017.
//  Copyright © 2017 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {}

extension UIViewController: UIIdiomable {}

extension UIView: UIIdiomable {}

protocol UIIdiomable: AnyObject {
    var isPad: Bool { get }
}

extension UIIdiomable {
    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}
