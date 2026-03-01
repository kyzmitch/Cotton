//
//  ThemeProvider.swift
//  catowser
//
//  Created by Andrei Ermoshin on 22/01/2019.
//  Copyright © 2019 Cotton (former Catowser). All rights reserved.
//

import UIKit

/// Theme provider
@MainActor
public final class ThemeProvider {
    /// Shared instance of Theme provider
    public static let shared = ThemeProvider()

    static let disabledOpacity = 0.4

    var themeType: ThemeType {
        didSet {
            theme = themeType.theme
        }
    }

    public private(set) var theme: Theme

    /// Setup search bar view theme
    public func setup(_ searchBarView: UISearchBar) {
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
        toolbar.isTranslucent = false
        toolbar.barTintColor = .phoneToolbarColor
        // background color is `nil`
    }

    func setupUnderToolbar(_ view: UIView) {
        view.backgroundColor = .phoneToolbarColor
    }

    /// Setup under link tags
    public func setupUnderLinkTags(_ view: UIView) {
        view.backgroundColor = .linkTagsBackgroundColor
    }

    private init() {
        themeType = .default
        theme = themeType.theme
    }
}
