//
//  TabViewModel.swift
//  catowser
//
//  Created by Andrei Ermoshin on 7/22/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import Foundation
import CoreBrowser
import FeaturesFlagsKit

@MainActor
final class TabViewModel {
    private var tab: Tab
    private var visualState: Tab.VisualState
    
    @Published var state: TabViewState
    
    init(_ tab: Tab, _ visualState: Tab.VisualState) {
        self.tab = tab
        self.visualState = visualState
        
        state = .initial()
    }
    
    var title: String {
        tab.title
    }
    
    func loadFavicon() async -> ImageSource? {
        guard let site = tab.site else {
            return nil
        }
        if let hqImage = site.favicon() {
            return .image(hqImage)
        }
        let useDoH = await FeatureManager.shared.boolValue(of: .dnsOverHTTPSAvailable)
        let source: ImageSource
        // TODO: do a DNS request when useDoH is true
        switch (site.faviconURL(useDoH), site.favicon()) {
        case (let url?, nil):
            source = .url(url)
        case (nil, let image?):
            source = .image(image)
        case (let url?, let image?):
            source = .urlWithPlaceholder(url, image)
        default:
            return nil
        }
        return source
    }
    
    func close() {
        if let site = tab.site {
            WebViewsReuseManager.shared.removeController(for: site)
        }
        Task {
            await TabsListManager.shared.close(tab: tab)
        }
    }
    
    func activate() {
        Task {
            print("\(#function): selected tab with id: \(tab.id)")
            await TabsListManager.shared.select(tab: tab)
        }
    }
}

extension TabViewModel: TabsObserver {
    func tabDidSelect(index: Int, content: Tab.ContentType, identifier: UUID) async {
        if tab.id == identifier {
            // TODO: implement
        } else {
            
        }
    }
    
    func tabDidReplace(_ tab: Tab, at index: Int) async {
        self.tab = tab
        state = state.withNew(tab.title)
    }
}
