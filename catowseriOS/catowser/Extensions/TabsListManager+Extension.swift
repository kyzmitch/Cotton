//
//  TabsListManager+Extension.swift
//  catowser
//
//  Created by Andrei Ermoshin on 10/18/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CoreBrowser
import UIKit

/// manager's extension to not bring UIKit to CoreBrowser module
extension TabsListManager {
    /// Updates preview image for selected tab if it has site content.
    ///
    /// - Parameter image: `UIImage` usually a screenshot of WKWebView.
    func setSelectedPreview(_ image: UIImage?) async throws {
        var tab = try await selectedTab()
        let tabIndex = try await selectedIndex()
        
        if case .site = tab.contentType, image == nil {
            throw TabsListError.wrongTabContent
        }
        tab.preview = image
        try replaceInMemory(tab, tabIndex)
    }
}
