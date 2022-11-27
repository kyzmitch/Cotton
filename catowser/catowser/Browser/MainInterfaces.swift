//
//  MainInterfaces.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/1/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import UIKit
import JSPlugins
import CoreHttpKit
import CoreBrowser

protocol MainDelegate: AnyObject {
    var popoverSourceView: UIView { get }
}
