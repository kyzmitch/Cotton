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
    
    public let backgroundColourSelected = UIColor.lightGray
    public let backgroundColourDeselected = UIColor.darkGray
    public let tabCurvesColourSelected = UIColor.lightGray
    public let tabCurvesColourDeselected = UIColor.darkGray
    public let titleColourSelected = UIColor.black
    public let titleColourDeselected = UIColor.lightGray
    public let realBackgroundColour = UIColor.clear
    public let tabSize = CGSize(width: UIConstants.tabWidth(), height: UIConstants.tabHeight)
    public func preparedTitle() -> String {
        return model.title
    }
    public var selected: Bool
}
