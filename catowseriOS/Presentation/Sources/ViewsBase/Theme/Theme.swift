//
//  Theme.swift
//  catowser
//
//  Created by Andrei Ermoshin on 22/01/2019.
//  Copyright © 2019 Cotton (former Catowser). All rights reserved.
//

import UIKit

/// Application theme (TODO: need to be moved to design system)
public protocol Theme {
    /// Status bar style
    var statusBarStyle: UIStatusBarStyle { get }
    /// Search bar button background color
    var searchBarButtonBackgroundColor: UIColor { get }
    /// Search bar separator color
    var searchBarSeparatorColor: UIColor { get }
}

extension Theme {
    /// Status bar style
    public var statusBarStyle: UIStatusBarStyle {
        return .default
    }

    /// Search bar separator color
    public var searchBarSeparatorColor: UIColor {
        return #colorLiteral(red: 0.9176470588, green: 0.9176470588, blue: 0.9176470588, alpha: 1)
    }
}

enum ThemeType {
    case `default`

    var theme: Theme {
        switch self {
        case .default:
            return LightTheme()
        }
    }
}
