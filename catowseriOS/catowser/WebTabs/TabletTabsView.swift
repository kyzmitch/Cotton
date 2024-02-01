//
//  TabletTabsView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 1/13/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI

struct TabletTabsView: View {
    private let mode: SwiftUIMode
    @EnvironmentObject private var viewModel: AllTabsViewModel
    
    init(_ mode: SwiftUIMode) {
        self.mode = mode
    }
    
    var body: some View {
        TabletTabsLegacyView(viewModel)
            .frame(height: .tabHeight)
    }
}
