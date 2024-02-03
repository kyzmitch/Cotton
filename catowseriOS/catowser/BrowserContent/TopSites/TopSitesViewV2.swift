//
//  TopSitesViewV2.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/24/23.
//  Copyright © 2023 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import SwiftUI
import CottonBase
import CoreBrowser

@available(iOS 14.0, *)
struct TopSitesViewV2: View {
    private let vm: TopSitesViewModel
    @State private var selected: Site?
    
    init(_ vm: TopSitesViewModel) {
        self.vm = vm
    }
    
    /// Number of items which will be displayed in a row
    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: ImageViewSizes.spacing) {
                ForEach(vm.topSites) { TitledImageView($0, $selected) }
            }
        }
        .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
        .onChange(of: selected) { newValue in
            guard let newValue else {
                return
            }
            vm.replaceSelected(tabContent: .site(newValue))
        }
    }
}
