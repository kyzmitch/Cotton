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
    private var titleColour: UIColor?
    private var iconUrl: URL?
    private var url: URL?
    
    init(tabTitle: String) {
        self.init(tabTitle: tabTitle, tabTitleColour: nil, tabIconUrl: nil)
    }
    
    init(tabTitle: String, tabTitleColour: UIColor?, tabIconUrl: URL?) {
        title = tabTitle
        titleColour = tabTitleColour
        iconUrl = url
    }
}
