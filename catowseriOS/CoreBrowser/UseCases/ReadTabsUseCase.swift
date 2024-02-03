//
//  ReadTabsUseCase.swift
//  CoreBrowser
//
//  Created by Andrey Ermoshin on 04.01.2024.
//  Copyright © 2024 Cotton (former Catowser). All rights reserved.
//

import Foundation

public protocol ReadTabsUseCase: BaseUseCase {
    /// Returns tabs count
    var tabsCount: Int { get async }
    /// Returns selected UUID, could be invalid one which is defined (to handle always not empty condition)
    var selectedId: UUID { get async }
    /// Fetches latest tabs.
    var allTabs: [Tab] { get async }
}
