//
//  TabAction.swift
//  CottonViewModels
//
//  Copyright © 2026 Cotton (Catowser). All rights reserved.
//

import ViewModelKit

/// Actions for Tab domain state transitions.
public enum TabAction: ViewModelAction {
    /// Resolve selection + favicon and publish chrome for the tab.
    case load
    /// Flip selected/deselected chrome without reloading favicon.
    case applySelection(isSelected: Bool)
    /// Update title and favicon after a tab content replace.
    case applyReplace(title: String, favicon: ImageSource?)
    /// Close the tab (side effect); published state unchanged.
    case close
    /// Activate/select the tab (side effect); selection chrome arrives via observer.
    case activate

    /// Representative cases for `ViewModelAction` / `CaseIterable`.
    public static var allCases: [TabAction] {
        [
            .load,
            .applySelection(isSelected: false),
            .applyReplace(title: "", favicon: nil),
            .close,
            .activate
        ]
    }
}
