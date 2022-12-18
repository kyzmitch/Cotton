//
//  BrowserContentView.swift
//  catowser
//
//  Created by Andrey Ermoshin on 14.12.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI

struct BrowserContentView: View {
    @EnvironmentObject var model: BrowserContentModel
    
    var body: some View {
        switch model.contentType {
        case .blank:
            EmptyView()
                .background(.white)
        case .topSites:
            TopSitesView()
                .environmentObject(TopSitesModel())
        default:
            EmptyView()
        }
        
    }
}
