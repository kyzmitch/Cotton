//
//  WebViewsReuseManager.swift
//  catowser
//
//  Created by Andrei Ermoshin on 07/02/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser
import JSPlugins
import HttpKit

/// The class to control memory usage by managing reusage of web views
final class WebViewsReuseManager {
    static let shared = WebViewsReuseManager()
    /// Web view controllers array, array is used to have ordering and current index
    /// But NSMapTable could be better by using Sites as keys for web views.
    private var views: [WebViewController]
    /// How many views to store
    private let viewsLimit: Int
    /// Needed to store index of last returned view
    private var lastSelectedIndex: Int?
    
    private let useLimitedCache = false

    private init(_ viewsLimit: Int = 10) {
        assert(viewsLimit >= 1, "Not possible view limit")
        views = [WebViewController]()
        if viewsLimit >= 1 {
            self.viewsLimit = viewsLimit
        } else {
            self.viewsLimit = 2
        }
    }
    
    private func searchWebViewIndex(for site: Site) -> Int? {
        for (i, vc) in views.enumerated() {
            let currentUrl = vc.urlInfo.domainURL
            if currentUrl == site.urlInfo.domainURL {
                return i
            }
        }
        return nil
    }

    /// Returns already created view with updated site or creates new one.
    ///
    /// - Parameter site: The site object with all info for WebView.
    /// - Parameter pluginsBuilder: Builder for plugins.
    /// - Parameter delegate: navigation delegate.
    /// - Returns: Web view controller configured with `Site`.
    func controllerFor(_ site: Site,
                       pluginsBuilder: PluginsBuilder,
                       delegate: SiteExternalNavigationDelegate) throws -> WebViewController {
        // need to search web view with same url as in `site` to restore navigation history
        if useLimitedCache,
            let index = searchWebViewIndex(for: site),
            let vc = views[safe: index] {
            lastSelectedIndex = index
            return vc
        }

        // if that url is not present in any of existing web views, then
        // need to check if browser still hasn't exceeded web views limit
        // then need to create completely new web view
        let count = views.count
        if count >= 0 && count < viewsLimit {
            let vc = WebViewController(site,
                                       plugins: pluginsBuilder.plugins,
                                       externalNavigationDelegate: delegate,
                                       dnsHttpClient: GoogleDnsClient.shared)
            views.append(vc)
            lastSelectedIndex = count
            return vc
        }

        guard let selectedIndex = lastSelectedIndex else {
            // Not possible case actually, so, adding exception will not make sense
            // and at the same time creating view controller here is not good.
            // Also, need to have non Optional return value.
            // Another option is to initialize `lastSelectedIndex` with any number
            // anyway it will be changed to correct one in a check above when
            // collection is not full.
            struct NotSelectedIndex: Error {}
            throw NotSelectedIndex()
        }

        // if the limit is already reached, then need reuse oldest tab
        // but, after testing it turns out that sometimes it is buggy
        // to use old web view for new entered query
        let nextIndex: Int
        if selectedIndex + 1 < count - 1 {
            nextIndex = selectedIndex + 1
        } else {
            nextIndex = 0
        }

        guard let vc = views[safe: nextIndex] else {
            struct OutOfBoundsIndex: Error {}
            throw OutOfBoundsIndex()
        }
        vc.load(site: site, canLoadPlugins: site.settings.canLoadPlugins)
        return vc
    }
    
    @discardableResult
    func removeController(for site: Site) -> Bool {
        guard let index = searchWebViewIndex(for: site) else { return false }
        views.remove(at: index)
        return true
    }
}
