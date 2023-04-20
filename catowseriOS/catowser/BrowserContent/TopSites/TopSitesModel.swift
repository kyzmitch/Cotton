//
//  TopSitesModel.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/17/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CottonCoreBaseKit

final class TopSitesModel {
    let topSites: [Site]
    
    init() {
        topSites = DefaultTabProvider.shared.topSites
    }
}
