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
    private let readTabUseCase: ReadTabsUseCase
    private let writeTabUseCase: WriteTabsUseCase
    
    @Published var state: TabViewState
    
    init(_ tab: Tab, 
         _ readTabUseCase: ReadTabsUseCase,
         _ writeTabUseCase: WriteTabsUseCase) {
        self.tab = tab
        self.readTabUseCase = readTabUseCase
        self.writeTabUseCase = writeTabUseCase
    }
    
    // MARK: - public functions
    
    func load() {
        Task {
            let selectedTabId = await readTabUseCase.selectedId
            let visualState = tab.getVisualState(selectedTabId)
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
    }
    
    func close() {
        if let site = tab.site {
            WebViewsReuseManager.shared.removeController(for: site)
        }
        Task {
            await writeTabUseCase.close(tab: tab)
        }
    }
    
    func activate() {
        print("\(#function): selected tab with id: \(tab.id)")
        Task {
            await writeTabUseCase.select(tab: tab)
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
            /// Need to reload favicon and title as well.
            /// Not sure if it is possible during simple select?
        }
        /// Next code used to change tab's VisualState `tab.getVisualState(identifier)`
        if tab.id == identifier {
            state = state.selected()
        } else {
            state = state.deSelected()
        }
    }
    
    func tabDidReplace(_ tab: Tab, at index: Int) async {
        guard self.tab.id == tab.id else {
            return
        }
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
