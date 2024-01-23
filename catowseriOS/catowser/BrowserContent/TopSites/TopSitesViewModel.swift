//
//  TopSitesViewModel.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/17/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CottonBase
import CoreBrowser

final class TopSitesViewModel: ObservableObject {
    let topSites: [Site]
    private let writeTabUseCase: WriteTabsUseCase
    
    init(_ isJsEnabled: Bool,
         _ writeTabUseCase: WriteTabsUseCase) {
        topSites = DefaultTabProvider.shared.topSites(isJsEnabled)
        self.writeTabUseCase = writeTabUseCase
    }
    
    func replaceSelected(tabContent: Tab.ContentType) {
        Task {
            _ = await writeTabUseCase.replaceSelected(tabContent)
        }
    }
}
