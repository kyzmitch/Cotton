//
//  BrowserViewModel.swift
//  catowser
//
//  Created by admin on 18/06/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import Foundation
import UIKit

struct BrowserViewModel {
    public let tabsContainerHeight = UIConstants.tabHeight
    static public let browserBackgroundColour : UIColor = {
        #if swift(>=4.0)
            return UIColor(red: 192/255.0, green: 240/255.0, blue: 144/255.0, alpha: 1.0)
        #else
            return UIColor(colorLiteralRed: 192/255.0, green: 240/255.0, blue: 144/255.0, alpha: 1.0)
        #endif
    }()
}
