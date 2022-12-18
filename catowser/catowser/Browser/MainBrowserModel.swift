//
//  MainBrowserModel.swift
//  catowser
//
//  Created by Andrey Ermoshin on 14.12.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Combine
import SwiftUI

final class MainBrowserModel<C: LimitedAppCoordinator>: ObservableObject {
    /// Max value should be 1.0 because total is equals to that by default
    @State var websiteLoadProgress: Double
    @State var showProgress: Bool
    
    weak var coordinator: C?
    
    init() {
        websiteLoadProgress = 0.0
        showProgress = false
    }
}
