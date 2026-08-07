//
//  TopSitesViewModel.swift
//  CottonViewModels
//
//  Created by Andrei Ermoshin on 12/17/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import CottonBase
import CoreBrowser
import ViewModelKit

/// Kit-backed Top Sites view model.
public typealias TopSitesViewModel = BaseViewModel<
    TopSitesViewState<TopSitesStateContextProxy>,
    TopSitesAction,
    TopSitesStateContextProxy
>

extension TopSitesViewModel {
    /// Sites displayed in the top-sites grid.
    public var topSites: [Site] {
        state.sites
    }

    /// Fire-and-forget replace of the selected tab; only calls `sendAction`.
    public func replaceSelected(tabContent: CoreBrowser.Tab.ContentType) {
        sendAction(.replaceSelected(tabContent))
    }
}
