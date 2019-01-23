//
//  ThemeProvider.swift
//  catowser
//
//  Created by Andrei Ermoshin on 22/01/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit

final class ThemeProvider {
    static let shared = ThemeProvider()

    var themeType: ThemeType {
        didSet {
            theme = themeType.theme
        }
    }

    private(set) var theme: Theme

    func setup(_ searchBarView: UISearchBar) {
        searchBarView.barTintColor = UIColor.white
        searchBarView.tintColor = UIColor.black
        searchBarView.barStyle = .default
        searchBarView.isTranslucent = false
    }

    private init() {
        themeType = .default
        theme = themeType.theme
    }
}
