//
//  MainBrowserView.swift
//  catowser
//
//  Created by Andrey Ermoshin on 10.12.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI

struct MainBrowserView: View {
    var body: some View {
        if isPad {
            tabletView()
        } else {
            phoneView()
        }
    }
}

private extension MainBrowserView {
    func tabletView() -> some View {
        VStack {
            SearchBarView()
        }
    }
    
    func phoneView() -> some View {
        VStack {
            SearchBarView()
            Spacer()
            ToolbarView()
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    DummyView()
                }
        }
    }
}

private struct DummyView: View {
    var body: some View {
        Divider()
            .frame(height: 0)
            .background(Color.phoneToolbarColor)
    }
}

#if DEBUG
struct MainBrowserView_Previews: PreviewProvider {
    static var previews: some View {
        MainBrowserView()
    }
}
#endif
