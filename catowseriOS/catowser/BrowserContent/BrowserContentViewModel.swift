//
//  BrowserContentViewModel.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/17/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import SwiftUI
import CoreBrowser
import CottonPlugins

/// Content view model which observes for the currently selected tab content type.
/// This reference type should be used to update the view if content changes.
@MainActor final class BrowserContentViewModel: ObservableObject {
    /// View content type. https://stackoverflow.com/a/56724174
    @Published var contentType: CoreBrowser.Tab.ContentType
    /// Tab's content loading
    @Published var loading: Bool
    /// Web view needs an update after changing selected tab content.
    /// Void type can be used because this model only can set it to true.
    @Published var webViewNeedsUpdate: Void
    /// Tabs count
    @Published var tabsCount: Int
    /// JS plugins builder reference
    let jsPluginsBuilder: any JSPluginsSource
    /// Not initialized, will be initialized after `TabsListManager`
    /// during tab opening. Used only during tab opening for optimization
    private var previousTabContent: CoreBrowser.Tab.ContentType?
    /// To avoid app start case
    private var firstTabContentSelect: Bool

    init(_ jsPluginsBuilder: any JSPluginsSource, _ defaultContentType: CoreBrowser.Tab.ContentType) {
        firstTabContentSelect = true
        self.jsPluginsBuilder = jsPluginsBuilder
        self.contentType = defaultContentType
        loading = true
        webViewNeedsUpdate = ()
        tabsCount = 0
    }
}

extension BrowserContentViewModel: TabsObserver {
    func tabDidSelect(_ index: Int, _ content: CoreBrowser.Tab.ContentType, _ identifier: UUID) async {
        if let previousValue = previousTabContent, previousValue.isStatic && previousValue == content {
            // Optimization to not do remove & insert of the same static view
            return
        }
        if loading {
            loading = false
        }
        // This is the only good place where to determine
        // if web view which can only be re-used in SwiftUI
        // and not re-created that it needs an update
        // because selected tab content was changed.
        // This can't be safely determined by comparing
        // currently used tab content with selected one
        if firstTabContentSelect {
            firstTabContentSelect = false
        } else {
            webViewNeedsUpdate = ()
        }

        if contentType != content {
            contentType = content
        }
    }

    func tabDidReplace(_ tab: CoreBrowser.Tab, at index: Int) async {
        if loading {
            loading = false
        }
        if contentType != tab.contentType {
            contentType = tab.contentType
        }
    }

    func updateTabsCount(with tabsCount: Int) async {
        self.tabsCount = tabsCount
    }
}
