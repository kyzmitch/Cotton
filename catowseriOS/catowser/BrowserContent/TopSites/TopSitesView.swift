//
//  TopSitesView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/17/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI

struct TopSitesView: View {
    let model: TopSitesModel
    /// Selected swiftUI mode which is set at app start
    private let mode: SwiftUIMode
    
    init(_ model: TopSitesModel, _ mode: SwiftUIMode) {
        self.model = model
        self.mode = mode
    }
    
    var body: some View {
        switch mode {
        case .compatible:
            TopSitesLegacyView(model: model)
        case .full:
            Spacer()
        }
    }
}
