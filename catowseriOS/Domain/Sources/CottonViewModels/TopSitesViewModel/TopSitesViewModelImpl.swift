//
//  TopSitesViewModelImpl.swift
//  CottonViewModels
//
//  Copyright © 2026 Cotton (Catowser). All rights reserved.
//

import CottonBase
import CoreBrowser
import CottonUseCases
import ViewModelKit

/// Top Sites view model implementation on ViewModelKit.
@MainActor final class TopSitesViewModelImpl: TopSitesViewModel {
    private let writeTabUseCase: any ReplaceSelectedTabUseCase
    private lazy var proxy = TopSitesStateContextProxy(subject: self)

    init(
        _ topSites: [Site],
        _ writeTabUseCase: any ReplaceSelectedTabUseCase
    ) {
        self.writeTabUseCase = writeTabUseCase
        super.init(transitioning: TopSitesStateTransitioning())
        // One-time seed: show sites immediately (same UX as pre-kit init).
        state = .init(sites: topSites)
    }

    public override var context: Context? {
        proxy
    }
}

// MARK: - TopSitesStateContext

extension TopSitesViewModelImpl: TopSitesStateContext {
    public func replaceSelectedTab(with content: CoreBrowser.Tab.ContentType) async {
        do {
            try await writeTabUseCase.execute(input: content)
        } catch {
            print("Fail to replace current tab: \(error)")
        }
    }
}
