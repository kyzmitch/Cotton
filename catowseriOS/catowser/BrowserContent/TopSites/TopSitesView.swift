//
//  TopSitesView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/17/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI

struct TopSitesView: View {
    let vm: TopSitesViewModel
    /// Selected swiftUI mode which is set at app start
    private let mode: SwiftUIMode
    
    init(_ vm: TopSitesViewModel, _ mode: SwiftUIMode) {
        self.vm = vm
        self.mode = mode
    }
    
    var body: some View {
        switch mode {
        case .compatible:
            TopSitesLegacyView(vm)
        case .full:
            TopSitesViewV2(vm)
        }
    }
}
