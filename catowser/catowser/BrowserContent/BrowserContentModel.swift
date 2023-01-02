//
//  BrowserContentModel.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/17/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI
import CoreBrowser

/// Content view model which observes for the currently selected tab content type.
/// This reference type should be used to update the view if content changes.
final class BrowserContentModel: ObservableObject {
    /// View content type. https://stackoverflow.com/a/56724174
    @Published var contentType: Tab.ContentType
    /// Tab's content loading
    @Published var loading: Bool
    /// JS plugins builder reference
    let jsPluginsBuilder: any JSPluginsSource
    /// Not initialized, will be initialized after `TabsListManager`
    /// during tab opening. Used only during tab opening for optimization
    private var previousTabContent: Tab.ContentType?
    
    init(_ jsPluginsBuilder: any JSPluginsSource) {
        self.jsPluginsBuilder = jsPluginsBuilder
        contentType = DefaultTabProvider.shared.contentState
        loading = true
        TabsListManager.shared.attach(self)
    }
    
    deinit {
        TabsListManager.shared.detach(self)
    }
}

extension BrowserContentModel: TabsObserver {
    func tabDidSelect(index: Int, content: Tab.ContentType, identifier: UUID) {
        if let previousValue = previousTabContent, previousValue.isStatic && previousValue == content {
            // Optimization to not do remove & insert of the same static view
            return
        }
        loading = false
        contentType = content
    }
    
    func tabDidReplace(_ tab: Tab, at index: Int) {
        loading = false
        contentType = tab.contentType
    }
}
