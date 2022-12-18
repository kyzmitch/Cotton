//
//  MainBrowserView.swift
//  catowser
//
//  Created by Andrey Ermoshin on 10.12.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI

struct MainBrowserView<C: LimitedAppCoordinator>: View {
    private let model: MainBrowserModel<C>
    
    init(model: MainBrowserModel<C>) {
        self.model = model
    }
    
    var body: some View {
        _MainBrowserView<C>()
            .environmentObject(model)
    }
}

private struct _MainBrowserView<C: LimitedAppCoordinator>: View {
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
                .environmentObject(BrowserContentModel(model.coordinator))
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
class DummyCoordinatorInterface: CoordinatorsInterface {
    var topSitesCoordinator: TopSitesCoordinator? {
        return nil
    }
}

class DummyDelegate: LimitedAppCoordinator {
    var coordinators: CoordinatorsInterface {
        DummyCoordinatorInterface()
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
