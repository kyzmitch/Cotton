//
//  TabsPreviewsViewModel.swift
//  catowser
//
//  Created by Andrey Ermoshin on 21.01.2024.
//  Copyright © 2024 andreiermoshin. All rights reserved.
//

import Foundation
import CoreBrowser

typealias TabsBox = Box<[Tab]>

enum TabsPreviewState {
    /// Maybe it is not needed state, but it is required for scalability when some user will have 100 tabs
    case loading
    /// Actual collection for tabs, at least one tab always will be in it
    case tabs(dataSource: TabsBox)

    var itemsNumber: Int {
        switch self {
        case .loading:
            return 0
        case .tabs(let box):
            return box.value.count
        }
    }
}

final class TabsPreviewsViewModel {
    @Published var uxState: TabsPreviewState = .loading
    private let readTabUseCase: ReadTabsUseCase
    private let writeTabUseCase: WriteTabsUseCase
    
    init(_ readTabUseCase: ReadTabsUseCase,
         _ writeTabUseCase: WriteTabsUseCase) {
        self.readTabUseCase = readTabUseCase
        self.writeTabUseCase = writeTabUseCase
    }
    
    func load() {
        Task {
            let tabs = await readTabUseCase.allTabs
            uxState = .tabs(dataSource: .init(tabs))
        }
    }
    
    func closeTab(at index: Int) {
        Task {
            guard case let .tabs(box) = uxState else {
                return
            }
            let tab = box.value.remove(at: index)
            /// Rewrite view model state with the updated box
            uxState = .tabs(dataSource: box)
            if let site = tab.site {
                await WebViewsReuseManager.shared.removeController(for: site)
            }
            await writeTabUseCase.close(tab: tab)
        }
    }
}
