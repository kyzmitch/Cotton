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
    
    public var title: String
    public var titleColour: UIColor?
    public var iconUrl: URL?
    public var url: URL?
    
    init(tabTitle: String) {
        self.init(tabTitle: tabTitle, tabTitleColour: UIColor.black, tabIconUrl: nil)
    }
    
    init(tabTitle: String, tabTitleColour: UIColor?, tabIconUrl: URL?) {
        title = tabTitle
        titleColour = tabTitleColour
        iconUrl = url
    }
}
