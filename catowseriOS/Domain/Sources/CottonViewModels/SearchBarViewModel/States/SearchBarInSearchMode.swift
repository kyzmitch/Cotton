//
//  SearchBarInSearchMode.swift
//  catowser
//
//  Created by Andrey Ermoshin on 04.01.2025.
//  Copyright © 2025 Cotton (Catowser). All rights reserved.
//

/// Search mode state (or search suggestions mode)
public final class SearchBarInSearchMode<C: SearchBarStateContext>: SearchBarState<C>, @unchecked Sendable {
    private let handler = SearchBarInSearchModeHandler<C>()

    /// Init
    /// - Parameter query: optional search request text
    /// - Parameter overlayContent: text for overlay label
    /// - Parameter searchBarContent: text for search bar
    public init(
        _ query: String?,
        _ overlayContent: String?,
        _ searchBarContent: String?
    ) {
        super.init()
        self.query = query
        self.overlayContent = overlayContent
        self.searchBarContent = searchBarContent
    }

    @MainActor public override var modeHandler: any SearchBarModeHandler<C> {
        handler
    }

    public override var showCancelButton: Bool {
        true
    }
}
