//
//  BrowserContentView.swift
//  catowser
//
//  Created by Andrey Ermoshin on 14.12.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI
import CoreBrowser
import JSPlugins

/**
 To avoid this, always declare state as private,
 and place it in the highest view in the view hierarchy that needs access to the value.
 https://developer.apple.com/documentation/swiftui/state
 
 Sooo, can't use state properties in model types, WTF???
 */

struct BrowserContentView: View {
    @EnvironmentObject var model: BrowserContentModel
    /// view state
    @State private var contentType: Tab.ContentType = DefaultTabProvider.shared.contentState
    /// Not initialized, will be initialized after `TabsListManager`
    /// during tab opening. Used only during tab opening for optimization
    private var previousTabContent: Tab.ContentType?
    
    init() {
        TabsListManager.shared.attach(self)
    }
    
    var body: some View {
        switch contentType {
        case .blank:
            EmptyView()
                .background(.white)
        case .topSites:
            TopSitesView()
                .environmentObject(TopSitesModel())
        case .site(let site):
            WebViewV2()
                .environmentObject(WebViewSwiftUIModel(site, model.jsPluginsBuilder))
        default:
            EmptyView()
        }
    }
}

extension BrowserContentView: TabsObserver {
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

#if DEBUG

// https://martinlasek.medium.com/swiftui-understanding-binding-8e20269a76bc

class DummyJSPluginsSource: JSPluginsSource {
    typealias Program = JSPluginsProgramImpl
    var pluginsProgram: Program {
        JSPluginsProgramImpl([])
    }
}

struct BrowserContentView_Previews: PreviewProvider {
    static let model: BrowserContentModel = {
        let source: DummyJSPluginsSource = .init()
        return .init(source)
    }()
    
    static var previews: some View {
        EmptyView()
    }
}

#endif
