//
//  TopSitesViewState.swift
//  CottonViewModels
//
//  Copyright © 2026 Cotton (Catowser). All rights reserved.
//

import CottonBase
import ViewModelKit

/// Concrete state type used by the Top Sites `BaseViewModel` adopter.
public typealias TopSitesState = TopSitesViewState<TopSitesStateContextProxy>

/// Top Sites view model state: the sites shown in the grid.
public struct TopSitesViewState<C: TopSitesStateContext>: ViewModelState, @unchecked Sendable {
    public typealias Context = C
    public typealias Action = TopSitesAction
    public typealias BaseState = TopSitesViewState<C>

    public let sites: [Site]

    public init(sites: [Site]) {
        self.sites = sites
    }

    public static func createInitial() -> BaseState {
        .init(sites: [])
    }
}
