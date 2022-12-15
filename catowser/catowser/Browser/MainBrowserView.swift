//
//  MainBrowserView.swift
//  catowser
//
//  Created by Andrey Ermoshin on 10.12.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI

struct MainBrowserView: View {
    let model: MainBrowserModel
    var body: some View {
        _MainBrowserView().environmentObject(model)
    }
}

private struct _MainBrowserView: View {
    @EnvironmentObject var model: MainBrowserModel
    
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
            if model.showProgress {
                ProgressView(value: model.websiteLoadProgress)
            }
            WebContentContainerView()
            Spacer()
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
struct MainBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        let model = MainBrowserModel()
        MainBrowserView(model: model)
    }
}
#endif
