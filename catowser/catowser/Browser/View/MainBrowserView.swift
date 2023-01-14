//
//  MainBrowserView.swift
//  catowser
//
//  Created by Andrey Ermoshin on 10.12.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI
import CoreBrowser

struct MainBrowserView<C: BrowserContentCoordinators>: View {
    private let model: MainBrowserModel<C>
    
    init(_ model: MainBrowserModel<C>) {
        self.model = model
    }
    
    var body: some View {
        _MainBrowserView<C>(model: model)
            .environment(\.browserContentCoordinators, model.coordinatorsInterface)
    }
}

private struct _MainBrowserView<C: BrowserContentCoordinators>: View {
    private var model: MainBrowserModel<C>
    
    init(model: MainBrowserModel<C>) {
        self.model = model
    }
    
    var body: some View {
        if isPad {
            TabletView(model)
        } else {
            PhoneView(model)
        }
    }
}
