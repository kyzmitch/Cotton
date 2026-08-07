//
//  TabStateContext.swift
//  CottonViewModels
//
//  Copyright © 2026 Cotton (Catowser). All rights reserved.
//

import ViewModelKit

/// Side-effect surface for Tab transitions without exposing the impl.
@MainActor public protocol TabStateContext: StateContext {
    /// Current tab title for load transitions.
    var tabTitle: String { get }
    /// Whether this tab is the selected tab.
    func isTabSelected() async throws -> Bool
    /// Resolve favicon for the current site (nil on soft-fail / no site).
    func loadFavicon() async -> ImageSource?
    /// Remove web view (if any) and close the tab via use case.
    func closeTab() async
    /// Select/activate this tab via use case.
    func activateTab() async
}

/// Proxy that hides the view model implementation from the transition strategy.
public final class TabStateContextProxy: TabStateContext {
    private let subject: any TabStateContext

    init(subject: any TabStateContext) {
        self.subject = subject
    }

    public var tabTitle: String {
        subject.tabTitle
    }

    public func isTabSelected() async throws -> Bool {
        try await subject.isTabSelected()
    }

    public func loadFavicon() async -> ImageSource? {
        await subject.loadFavicon()
    }

    public func closeTab() async {
        await subject.closeTab()
    }

    public func activateTab() async {
        await subject.activateTab()
    }
}
