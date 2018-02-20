//
//  TabsViewModel.swift
//  catowser
//
//  Created by admin on 18/06/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import Foundation
import UIKit

struct TabsViewModel {
    public var tabsContainerHeight: CGFloat
    public var topViewsOffset: CGFloat
    
    
    init(_ topOffset: CGFloat = UIConstants.topViewsOffset, _ heiht: CGFloat = UIConstants.tabHeight) {
        topViewsOffset = topOffset
        tabsContainerHeight = heiht
    }
}
