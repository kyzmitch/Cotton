//
//  ThemeProvider.swift
//  catowser
//
//  Created by Andrei Ermoshin on 22/01/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit

extension UIColor {
    static let phoneToolbarColor: UIColor = .white
}

final class ThemeProvider {
    static let shared = ThemeProvider()

    var themeType: ThemeType {
        didSet {
            theme = themeType.theme
        }
    }

    private(set) var theme: Theme

    func setup(_ searchBarView: UISearchBar) {
        // Trying to get rid of the 1px black line underneath the search bar
        // https://stackoverflow.com/a/8998710/483101
        searchBarView.backgroundColor = .white
        searchBarView.backgroundImage = UIImage()

        searchBarView.barTintColor = .white
        searchBarView.tintColor = .gray
        searchBarView.barStyle = .default
        searchBarView.isTranslucent = false
    }

    func setup(_ toolbar: UIToolbar) {
        toolbar.tintColor = .black
        toolbar.barTintColor = .phoneToolbarColor
        // background color is `nil`
    }

    func setupUnderToolbar(_ view: UIView) {
        view.backgroundColor = .phoneToolbarColor
    }

    private init() {
        themeType = .default
        theme = themeType.theme
    }
}
