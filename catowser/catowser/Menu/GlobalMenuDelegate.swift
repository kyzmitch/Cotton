//
//  GlobalMenuDelegate.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/6/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit

protocol GlobalMenuDelegate: AnyObject {
    func settingsDidPress(from sourceView: UIView, and sourceRect: CGRect)
}
