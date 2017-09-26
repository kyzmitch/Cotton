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
    private static let defaultTitle = NSLocalizedString("ttl_tab_short_blank", comment: "This is to show something on tab when it is without website address or title of web site")
    
    init(tabTitle: String = TabModel.defaultTitle, tabTitleColour: UIColor = UIColor.black, tabIconUrl: URL? = nil) {
        title = tabTitle
        titleColour = tabTitleColour
        iconUrl = url
    }
}
