//
//  AllTabsViewModel.swift
//  CottonViewModels
//
//  Created by Andrey Ermoshin on 21.01.2024.
//  Copyright © 2024 Cotton (former Catowser). All rights reserved.
//

import Combine
import Foundation
import CoreBrowser
import CottonUseCases
import ViewModelKit

public typealias AllTabsViewModel = BaseViewModel<
    AllTabsState<AllTabsStateContextProxy>,
    AllTabsAction,
    AllTabsStateContextProxy
>

/// All tabs view model implementation
final class AllTabsViewModelImpl: AllTabsViewModel {
    private let addTabUseCase: any AddTabUseCase
    private lazy var proxy = {
        AllTabsStateContextProxy(subject: self)
    }()

    /// Internal initializer
    init(_ addTabUseCase: any AddTabUseCase) {
        self.addTabUseCase = addTabUseCase
        super.init(transitioning: AllTabsStateTransitioning())
    }

    public override var context: Context? {
        proxy
    }
}

extension AllTabsViewModelImpl: AllTabsStateContext {
    public func handleTabAdd(_ tab: CoreBrowser.Tab) {
        Task {
            do {
                try await addTabUseCase.execute(input: tab)
            } catch {
                print("Fail to add new tab: \(error)")
            }
        }
    }
}
