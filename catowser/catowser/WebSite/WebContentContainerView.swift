//
//  WebContentContainerView.swift
//  catowser
//
//  Created by Andrey Ermoshin on 14.12.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI
import CoreBrowser

struct WebContentContainerView: View {
    @State var contentType: Tab.ContentType = .blank
    var body: some View {
        switch contentType {
        case .blank:
            EmptyView()
                .background(.white)
        default:
            EmptyView()
        }
        
    }
}
