//
//  SearchBarInViewMode.swift
//  catowser
//
//  Created by Andrey Ermoshin on 04.01.2025.
//  Copyright © 2025 Cotton (Catowser). All rights reserved.
//

/// View mode state
public final class SearchBarInViewMode<C: SearchBarStateContext>: SearchBarState<C>, @unchecked Sendable {
    private let handler = SearchBarInViewModeHandler<C>()

    /// Initializer
    /// - Parameter overlayContent: text for overlay label from previous state
    /// - Parameter searchBarContent: text for search bar from previous state
    init(
        _ overlayContent: String? = nil,
        _ searchBarContent: String? = nil
    ) {
        super.init()
        self.overlayContent = overlayContent
        self.searchBarContent = searchBarContent
    }

    @MainActor public override var modeHandler: any SearchBarModeHandler<C> {
        handler
    }

    public override var showCancelButton: Bool {
        false
    }
}
