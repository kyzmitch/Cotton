//
//  TopSitesModel.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/17/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI
import CoreHttpKit

final class TopSitesModel: ObservableObject {
    let topSites: [Site]
    
    init() {
        topSites = DefaultTabProvider.shared.topSites
    }
}
