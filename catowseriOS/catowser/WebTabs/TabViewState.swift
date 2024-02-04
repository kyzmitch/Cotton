//
//  TabViewState.swift
//  catowser
//
//  Created by Andrei Ermoshin on 7/22/23.
//  Copyright © 2023 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation
import UIKit

struct TabViewState {
    let backgroundColor: UIColor
    let realBackgroundColour: UIColor
    let isSelected: Bool
    let titleColor: UIColor
    let title: String
    let favicon: ImageSource?

    init(_ backgroundColor: UIColor,
         _ realBackgroundColour: UIColor,
         _ isSelected: Bool,
         _ titleColor: UIColor,
         _ title: String,
         _ favicon: ImageSource?) {
        self.backgroundColor = backgroundColor
        self.realBackgroundColour = realBackgroundColour
        self.isSelected = isSelected
        self.titleColor = titleColor
        self.title = title
        self.favicon = favicon
    }

    static func selected(_ title: String, _ newFavicon: ImageSource?) -> TabViewState {
        TabViewState(.superLightGray, UIColor.clear, true, .lightGrayText, title, newFavicon)
    }

    static func deSelected(_ title: String, _ newFavicon: ImageSource?) -> TabViewState {
        .init(.normallyLightGray, UIColor.clear, false, .darkGrayText, title, newFavicon)
    }

    func withNew(_ title: String, _ newFavicon: ImageSource?) -> TabViewState {
        TabViewState(backgroundColor, realBackgroundColour, isSelected, titleColor, title, newFavicon)
    }

    func selected() -> TabViewState {
        TabViewState(.superLightGray, UIColor.clear, true, .lightGrayText, title, favicon)
    }

    func deSelected() -> TabViewState {
        TabViewState(.normallyLightGray, UIColor.clear, false, .darkGrayText, title, favicon)
    }
}
