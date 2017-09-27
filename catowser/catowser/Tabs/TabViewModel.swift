//
//  TabViewModel.swift
//  catowser
//
//  Created by admin on 12/06/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import Foundation
import UIKit

struct TabViewModel {
    private let model: TabModel
    init(tabModel: TabModel) {
        model = tabModel
        selected = false
    }
    
    public let backgroundColourSelected = UIColor.superLightGray
    public let backgroundColourDeselected = UIColor.normallyLightGray
    public let tabCurvesColourSelected = UIColor.superLightGray
    public let tabCurvesColourDeselected = UIColor.normallyLightGray
    public let titleColourSelected = UIColor.lightGrayText
    public let titleColourDeselected = UIColor.darkGrayText
    public let realBackgroundColour = UIColor.clear
    public let tabSize = CGSize(width: UIConstants.tabWidth(), height: UIConstants.tabHeight)
    public func preparedTitle() -> String {
        return model.title
    }
    public var selected: Bool
}

extension UIColor {
    static public let superLightGray = UIColor(displayP3Red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
    static public let normallyLightGray = UIColor(displayP3Red: 0.71, green: 0.71, blue: 0.71, alpha: 1.0)
    static public let darkGrayText = UIColor(displayP3Red: 0.32, green: 0.32, blue: 0.32, alpha: 1.0)
    static public let lightGrayText = UIColor(displayP3Red: 0.14, green: 0.14, blue: 0.14, alpha: 1.0)
}
