//
//  TopSitesStateContext.swift
//  CottonViewModels
//
//  Copyright © 2026 Cotton (Catowser). All rights reserved.
//

import CoreBrowser
import ViewModelKit

/// Side-effect surface for Top Sites transitions without exposing the impl.
@MainActor public protocol TopSitesStateContext: StateContext {
    /// Replace the selected tab with the given content type.
    func replaceSelectedTab(with content: CoreBrowser.Tab.ContentType) async
}

/// Proxy that hides the view model implementation from the transition strategy.
public final class TopSitesStateContextProxy: TopSitesStateContext {
    private let subject: any TopSitesStateContext

    init(subject: any TopSitesStateContext) {
        self.subject = subject
    }

    public func replaceSelectedTab(with content: CoreBrowser.Tab.ContentType) async {
        await subject.replaceSelectedTab(with: content)
    }
}
