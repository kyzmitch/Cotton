//
//  WebViewsReuseManager.swift
//  catowser
//
//  Created by Andrei Ermoshin on 07/02/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser

/// The class to control memory usage by managing reusage of web views
final class WebViewsReuseManager {
    static let shared = WebViewsReuseManager()
    /// Web view controllers array
    private var views: [WebViewController]
    /// How many views to store
    private let viewsLimit: Int
    /// Needed to store index of last returned view
    private var lastSelectedIndex: Int?

    private init(_ viewsLimit: Int = 2) {
        assert(viewsLimit >= 1, "Not possible view limit")
        views = [WebViewController]()
        if viewsLimit >= 1 {
            self.viewsLimit = viewsLimit
        } else {
            self.viewsLimit = 2
        }
    }

    /// Returns already created view with updated site or creates new one.
    ///
    /// - Parameter site: The site object with all info for WebView.
    /// - Returns: Web view controller configured with `Site`.
    func getControllerFor(_ site: Site) throws -> WebViewController {
        let count = views.count
        if views.isEmpty || count < viewsLimit {
            let vc = WebViewController(site)
            views.append(vc)
            lastSelectedIndex = count
            return vc
        } else {
            guard let lastIndex = lastSelectedIndex else {
                // Not possible case actually, so, adding exception will not make sense
                // and at the same time creating view controller here is not good.
                // Also, need to have non Optional return value.
                // Another option is to initialize `lastSelectedIndex` with any number
                // anyway it will be changed to correct one in check above when
                // collection is not full.
                struct NotSelectedIndex: Error {}
                throw NotSelectedIndex()
            }

            let nextIndex: Int
            if lastIndex + 1 < count {
                nextIndex = lastIndex + 1
            } else {
                nextIndex = 0
            }
            let vc = views[nextIndex]
            vc.site = site
            return vc
        }
    }
}
