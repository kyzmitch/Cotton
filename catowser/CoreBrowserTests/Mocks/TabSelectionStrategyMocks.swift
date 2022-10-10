//
//  TabSelectionStrategyMocks.swift
//  CoreBrowserTests
//
//  Created by Andrei Ermoshin on 10/9/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CoreBrowser

struct MockedTabSelectionStrategy: TabSelectionStrategy {
    func autoSelectedIndexAfterTabRemove(_ context: CoreBrowser.IndexSelectionContext, removedIndex: Int) -> Int {
        return 0
    }
    
    let makeTabActiveAfterAdding: Bool = true
}
