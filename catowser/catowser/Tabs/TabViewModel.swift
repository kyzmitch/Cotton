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
    }
    
    public let backgroundColour = UIColor.gray
    public let tabCurvesColour = UIColor.gray
    public let realBackgroundColour = UIColor.clear
    public let tabSize = CGSize(width: 180.0, height: 0.0)
}
