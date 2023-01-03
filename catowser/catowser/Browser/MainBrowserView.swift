//
//  MainBrowserView.swift
//  catowser
//
//  Created by Andrey Ermoshin on 10.12.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI

struct MainBrowserView<C: BrowserContentCoordinators>: View {
    @ObservedObject var model: MainBrowserModel<C>
    
    var body: some View {
        _MainBrowserView<C>(model: model)
            .environment(\.browserContentCoordinators, model.coordinatorsInterface)
    }
}

private struct _MainBrowserView<C: BrowserContentCoordinators>: View {
    @ObservedObject var model: MainBrowserModel<C>
    private let browserContentModel: BrowserContentModel
    @State private var webViewInterface: WebViewNavigatable?
    
    init(model: MainBrowserModel<C>) {
        self.model = model
        browserContentModel = BrowserContentModel(model.jsPluginsBuilder)
    }
    
    var body: some View {
        if isPad {
            tabletView()
        } else {
            phoneView()
        }
    }
}

private extension _MainBrowserView {
    func tabletView() -> some View {
        VStack {
            SearchBarView()
        }
    }
    
    func phoneView() -> some View {
        VStack {
            SearchBarView()
                .frame(height: CGFloat.searchViewHeight)
            if model.showProgress {
                ProgressView(value: model.websiteLoadProgress)
            }
            BrowserContentView(model: browserContentModel)
            ToolbarView(model: WebBrowserToolbarModel(), webViewInterface: $webViewInterface)
                // Allows to set same color for the space under toolbar
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    DummyView()
                }
        }
        // Allows to not have the toolbar be attached to keyboard.
        // So, the toolbar will stay on same position
        // even after keyboard became visible.
        .ignoresSafeArea(.keyboard)
        .onReceive(browserContentModel.$webViewInterface.drop(while: { value in
            value == nil
        })) { newWebViewInterface in
            // Updating the state to use that info in the toolbar view
            webViewInterface = newWebViewInterface
        }
    }
}

private struct DummyView: View {
    var body: some View {
        EmptyView()
            .frame(height: 0)
            .background(Color.phoneToolbarColor)
    }
}

#if DEBUG
class DummyDelegate: BrowserContentCoordinators {
    let topSitesCoordinator: TopSitesCoordinator? = nil
    let webContentCoordinator: WebContentCoordinator? =  nil
    let globalMenuDelegate: GlobalMenuDelegate? = nil
    let toolbarCoordinator: MainToolbarCoordinator? = nil
    let toolbarPresenter: AnyViewController? = nil
}

struct MainBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        let model = MainBrowserModel(DummyDelegate())
        MainBrowserView(model: model)
    }
}
#endif
