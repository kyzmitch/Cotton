//
//  MainBrowserView.swift
//  catowser
//
//  Created by Andrey Ermoshin on 10.12.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI

struct MainBrowserView<C: BrowserContentCoordinators>: View {
    private let model: MainBrowserModel<C>
    
    init(model: MainBrowserModel<C>) {
        self.model = model
    }
    
    var body: some View {
        _MainBrowserView<C>()
            .environment(\.browserContentCoordinators, model.coordinatorsInterface)
            .environmentObject(model)
    }
}

private struct _MainBrowserView<C: BrowserContentCoordinators>: View {
    @EnvironmentObject var model: MainBrowserModel<C>

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
            BrowserContentView()
                .environmentObject(BrowserContentModel())
            ToolbarView()
                // Allows to set same color for the space under toolbar
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    DummyView()
                }
        }
        // Allows to not have the toolbar be attached to keyboard.
        // So, the toolbar will stay on same position
        // even after keyboard became visible.
        .ignoresSafeArea(.keyboard)
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
    var topSitesCoordinator: TopSitesCoordinator? {
        nil
    }
}

struct MainBrowserView_Previews: PreviewProvider {
    let delegate = DummyDelegate()
    
    static var previews: some View {
        let model = MainBrowserModel<DummyDelegate>()
        MainBrowserView(model: model)
    }
}
#endif
