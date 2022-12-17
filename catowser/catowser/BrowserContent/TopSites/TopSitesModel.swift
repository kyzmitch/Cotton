//
//  TopSitesModel.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/17/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI

final class TopSitesModel: ObservableObject {
    weak var coordinator: AppDependable?
    
    init(_ coordinator: AppDependable?) {
        self.coordinator = coordinator
    }
}
