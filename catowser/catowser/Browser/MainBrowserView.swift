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
        }
    }
}
