//
//  Theme.swift
//  catowser
//
//  Created by Andrei Ermoshin on 22/01/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit

protocol Theme {
    var statusBarStyle: UIStatusBarStyle { get }
    var searchBarButtonBackgroundColor: UIColor { get }
    var searchBarSeparatorColor: UIColor { get }
}

extension Theme {
    var statusBarStyle: UIStatusBarStyle {
        return .default
    }

    var searchBarSeparatorColor: UIColor {
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
