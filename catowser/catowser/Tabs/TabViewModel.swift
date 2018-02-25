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
    
    let backgroundColourSelected = UIColor.superLightGray
    let backgroundColourDeselected = UIColor.normallyLightGray
    let tabCurvesColourSelected = UIColor.superLightGray
    let tabCurvesColourDeselected = UIColor.normallyLightGray
    let titleColourSelected = UIColor.lightGrayText
    let titleColourDeselected = UIColor.darkGrayText
    let realBackgroundColour = UIColor.clear
    func preparedTitle() -> String {
        return model.title
    }
    var selected: Bool
}

extension UIColor {
    // TODO: check colours if some of them are not used
    static let superLightGray = UIColor(displayP3Red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
    static let normallyLightGray = UIColor(displayP3Red: 0.71, green: 0.71, blue: 0.71, alpha: 1.0)
    static let darkGrayText = UIColor(displayP3Red: 0.32, green: 0.32, blue: 0.32, alpha: 1.0)
    static let lightGrayText = UIColor(displayP3Red: 0.14, green: 0.14, blue: 0.14, alpha: 1.0)
}
