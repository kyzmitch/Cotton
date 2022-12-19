//
//  BrowserContentModel.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/17/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI
import CoreBrowser

final class BrowserContentModel: ObservableObject {
    @State var contentType: Tab.ContentType
    /// Not initialized, will be initialized after `TabsListManager`
    /// during tab opening. Used only during tab opening for optimization
    private var previousTabContent: Tab.ContentType?
    ///
    let jsPluginsBuilder: any JSPluginsSource
    
    init(_ jsPluginsBuilder: any JSPluginsSource) {
        contentType = DefaultTabProvider.shared.contentState
        self.jsPluginsBuilder = jsPluginsBuilder
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
        contentType = content
    }
    
    func tabDidReplace(_ tab: Tab, at index: Int) {
        contentType = tab.contentType
    }
}
