//
//  ToolbarViewModel.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/21/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI
import CoreBrowser

final class ToolbarViewModel {
    @Binding var tabsCount: Int
    
    init(_ tabsCount: Binding<Int>) {
        _tabsCount = tabsCount
    }
}

extension ToolbarViewModel: TabsObserver {
    func update(with tabsCount: Int) {
        self.tabsCount = tabsCount
    }
}
