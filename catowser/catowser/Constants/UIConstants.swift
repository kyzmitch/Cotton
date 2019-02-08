//
//  UIConstants.swift
//  catowser
//
//  Created by admin on 20/09/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import Foundation
import UIKit

struct UIConstants {
    static let tabHeight = CGFloat(40.0)
    static let searchViewHeight = CGFloat(64.0)
    static let tabBarHeight = CGFloat(40.0) // system height?
    static let topViewsOffset = CGFloat(10)
    static var tabWidth: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 40.0
        }
        else if UIDevice.current.userInterfaceIdiom == .pad {
            return 180.0
        }
        else {
            return 180.0
        }
    }
    static let compactTabWidth = CGFloat(40.0)
    static let regularTabWidth = CGFloat(180.0)
    static let searchBarTextColour = UIColor.black
    static let searchBarBackgroundColour = UIColor.white
    
    static let webSiteTabHighlitedLineColour = UIColor(rgb: 0x0066DC)
    static let highlightLineWidth: CGFloat = 3
}

struct UIIdentifiers {
    static public let webSearchResultCellId = "WebSearchResultTableViewCell"
}
