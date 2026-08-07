//
//  TopSitesAction.swift
//  CottonViewModels
//
//  Copyright © 2026 Cotton (Catowser). All rights reserved.
//

import CoreBrowser
import ViewModelKit

/// Actions for Top Sites domain state transitions.
public enum TopSitesAction: ViewModelAction {
    /// Replace the selected tab with the given content (side effect).
    case replaceSelected(CoreBrowser.Tab.ContentType)

    /// Representative cases for `ViewModelAction` / `CaseIterable`.
    public static var allCases: [TopSitesAction] {
        [.replaceSelected(.topSites)]
    }
}
