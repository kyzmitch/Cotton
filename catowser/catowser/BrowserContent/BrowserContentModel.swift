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
    
    init() {
        contentType = DefaultTabProvider.shared.contentState
        TabsListManager.shared.attach(self)
    }
    
    deinit {
        TabsListManager.shared.detach(self)
    }
}

extension BrowserContentModel: TabsObserver {
    func tabDidSelect(index: Int, content: Tab.ContentType, identifier: UUID) {
        contentType = content
    }
    
    func tabDidReplace(_ tab: Tab, at index: Int) {
        
    }
}
