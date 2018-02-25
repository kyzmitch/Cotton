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
    static public let tabHeight = CGFloat(40.0)
    static public let searchViewHeight = CGFloat(64.0)
    static public let tabBarHeight = CGFloat(40.0) // system height?
    static public let topViewsOffset = CGFloat(10)
    static public func tabWidth() -> CGFloat {
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
    static public let compactTabWidth = CGFloat(40.0)
    static public let regularTabWidth = CGFloat(180.0)
    static public let searchBarTextColour = UIColor.black
    static public let searchBarBackgroundColour = UIColor.white
    
    static public let webSiteTabHighlitedLineColour = UIColor(rgb: 0x0066DC)
    static public let highlightLineWidth: CGFloat = 3
}

struct UIIdentifiers {
    static public let webSearchResultCellId = "WebSearchResultTableViewCell"
}
