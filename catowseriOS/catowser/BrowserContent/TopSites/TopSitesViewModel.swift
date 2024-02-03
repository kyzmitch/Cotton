//
//  TopSitesViewModel.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/17/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import CottonBase

final class TopSitesViewModel {
    let topSites: [Site]
    
    init(_ isJsEnabled: Bool) {
        topSites = DefaultTabProvider.shared.topSites(isJsEnabled)
    }
}
