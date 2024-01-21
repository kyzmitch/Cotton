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
    private let viewModel: AllTabsViewModel
    
    init(_ mode: SwiftUIMode, 
         _ viewModel: AllTabsViewModel) {
        self.mode = mode
        self.viewModel = viewModel
    }
    
    var body: some View {
        TabletTabsLegacyView(viewModel)
            .frame(height: .tabHeight)
    }
}
