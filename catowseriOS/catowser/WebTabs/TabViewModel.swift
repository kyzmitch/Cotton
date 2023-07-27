//
//  TabViewModel.swift
//  catowser
//
//  Created by Andrei Ermoshin on 7/22/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import Foundation
import CottonBase
import CoreBrowser
import FeaturesFlagsKit

@MainActor
final class TabViewModel {
    private var tab: Tab
    private var visualState: Tab.VisualState
    
    @Published var state: TabViewState
    
    init(_ tab: Tab, _ visualState: Tab.VisualState) async {
        self.tab = tab
        self.visualState = visualState
        
        let favicon: ImageSource?
        if let site = tab.site {
            favicon = await TabViewModel.loadFavicon(site)
        } else {
            favicon = nil
        }
        
        switch visualState {
        case .selected:
            state = .selected(tab.title, favicon)
        case .deselected:
            state = .deSelected(tab.title, favicon)
        }
    }
    
        // MARK: - public functions
    
    func close() {
        if let site = tab.site {
            WebViewsReuseManager.shared.removeController(for: site)
        }
        Task {
            await TabsListManager.shared.close(tab: tab)
        }
    }
    
    func activate() {
        print("\(#function): selected tab with id: \(tab.id)")
        Task {
            await TabsListManager.shared.select(tab: tab)
        }
    }
    
    // MARK: - private
    
    /// Loading of favicon doesn't depend on `self`
    private static func loadFavicon(_ site: Site) async -> ImageSource? {
        if let hqImage = site.favicon() {
            return .image(hqImage)
        }
        let resolveNeeded = await FeatureManager.shared.boolValue(of: .dnsOverHTTPSAvailable)
        let url: URL?
        do {
            url = try await site.faviconURL(resolveNeeded)
        } catch {
            print("Fail to resolve favicon url: \(error)")
            url = nil
        }
        
        let source: ImageSource
        switch (url, site.favicon()) {
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
}

extension TabViewModel: TabsObserver {
    func tabDidSelect(_ index: Int, _ content: Tab.ContentType, _ identifier: UUID) async {
        if tab.contentType != content {
            // Need to reload favicon and title as well.
            // Not sure if it is possible during simple select?
        }
        if tab.id == identifier {
            visualState = .selected
            state = state.selected()
        } else {
            visualState = .deselected
            state = state.deSelected()
        }
    }
    
    func tabDidReplace(_ tab: Tab, at index: Int) async {
        self.tab = tab
        let favicon: ImageSource?
        if let site = tab.site {
            favicon = await TabViewModel.loadFavicon(site)
        } else {
            favicon = nil
        }
        
        state = state.withNew(tab.title, favicon)
    }
}
