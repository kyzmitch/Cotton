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
}

extension Theme {
    var statusBarStyle: UIStatusBarStyle {
        return .default
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
