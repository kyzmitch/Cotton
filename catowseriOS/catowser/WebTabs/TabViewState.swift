//
//  TabViewState.swift
//  catowser
//
//  Created by Andrei Ermoshin on 7/22/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import Foundation
import UIKit

struct TabViewState {
    let backgroundColor: UIColor
    let realBackgroundColour: UIColor
    let isSelected: Bool
    let titleColor: UIColor
    let title: String
    
    init(_ backgroundColor: UIColor, _ realBackgroundColour: UIColor, _ isSelected: Bool, _ titleColor: UIColor, _ title: String) {
        self.backgroundColor = backgroundColor
        self.realBackgroundColour = realBackgroundColour
        self.isSelected = isSelected
        self.titleColor = titleColor
        self.title = title
    }
    
    func withNew(_ title: String) -> TabViewState {
        TabViewState(backgroundColor, realBackgroundColour, isSelected, titleColor, title)
    }
    
    static func initial() -> TabViewState {
        // TODO: implement default tab title
        .init(.normallyLightGray, UIColor.clear, false, .darkGrayText, "Title not implemented")
    }
}
