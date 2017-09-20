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
    
    public let backgroundColour = UIColor.lightGray
    public let tabCurvesColour = UIColor.lightGray
    public let realBackgroundColour = UIColor.clear
    public let tabSize = CGSize(width: 180.0, height: UIConstants.tabHeight)
    public func preparedTitle() -> String {
        return model.title
    }
    public var selected: Bool
}
