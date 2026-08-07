//
//  TabViewModel.swift
//  catowser
//
//  Created by Andrey Ermoshin on 17.12.2024.
//  Copyright © 2024 Cotton (Catowser). All rights reserved.
//

import ViewModelKit

/// Kit-backed Tab view model.
public typealias TabViewModel = BaseViewModel<
    TabViewState<TabStateContextProxy>,
    TabAction,
    TabStateContextProxy
>

extension TabViewModel {
    /// Fire-and-forget load; only calls `sendAction`.
    public func load() {
        sendAction(.load)
    }

    /// Fire-and-forget close; only calls `sendAction`.
    public func close() {
        sendAction(.close)
    }

    /// Fire-and-forget activate; only calls `sendAction`.
    public func activate() {
        sendAction(.activate)
    }
}
