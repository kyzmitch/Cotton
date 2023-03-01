//
//  TabsListManager+Extension.swift
//  catowser
//
//  Created by Andrei Ermoshin on 10/18/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CoreBrowser
import UIKit

extension TabsListManager {
    /// Updates preview image for selected tab if it has site content.
    ///
    /// - Parameter image: `UIImage` usually a screenshot of WKWebView.
    func setSelectedPreview(_ image: UIImage?) throws {
        var tab = try selectedTab()
        let tabIndex = try selectedIndex()
        
        if case .site = tab.contentType, image == nil {
            throw TabsListError.wrongTabContent
        }
        tab.preview = image
        try replaceInMemory(tab, tabIndex)
    }
}
