//
//  TabModel.swift
//  catowser
//
//  Created by admin on 12/06/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import Foundation
import UIKit

struct TabModel {
    
    private var title: String
    private let titleColour: UIColor
    private var iconUrl: URL?
    private var url: URL?
    
    init(tabTitle: String, tabTitleColour: UIColor) {
        self.init(tabTitle: tabTitle, tabTitleColour: tabTitleColour, tabIconUrl: nil)
    }
    
    init(tabTitle: String, tabTitleColour: UIColor, tabIconUrl: URL?) {
        title = tabTitle
        titleColour = tabTitleColour
        if let url = tabIconUrl {
            iconUrl = url
        }
        else {
            iconUrl = nil
        }
    }
}
