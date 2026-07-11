//
//  GlobalMenuDelegate.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/6/22.
//  Copyright © 2022 Cotton (former Catowser). All rights reserved.
//

import UIKit

/// Global menu delegate
@MainActor
public protocol GlobalMenuDelegate: AnyObject {
    /// Settings did press
    ///
    /// - Parameter sourceView: Source view
    /// - Parameter sourceRect: Source rectangle
    func settingsDidPress(from sourceView: UIView, and sourceRect: CGRect)
}
