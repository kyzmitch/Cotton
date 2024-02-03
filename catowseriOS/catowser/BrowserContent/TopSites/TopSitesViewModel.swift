//
//  TopSitesViewModel.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/17/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import CottonBase
import CoreBrowser

@MainActor
final class TopSitesViewModel: ObservableObject {
    let topSites: [Site]
    private let writeTabUseCase: WriteTabsUseCase
    
    init(_ topSites: [Site],
         _ writeTabUseCase: WriteTabsUseCase) {
        self.topSites = topSites
        self.writeTabUseCase = writeTabUseCase
    }
    
    func replaceSelected(tabContent: Tab.ContentType) {
        Task {
            _ = await writeTabUseCase.replaceSelected(tabContent)
        }
    }
}
