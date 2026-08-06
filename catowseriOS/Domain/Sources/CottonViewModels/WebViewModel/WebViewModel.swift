//
//  WebViewModel.swift
//  catowser
//
//  Created by Andrei Ermoshin on 7/26/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation
import CottonBase
import CottonPlugins
import FeatureFlagsKit
import Combine
import WebKit
import ViewModelKit

/// Kit-backed WebView view model base.
public typealias WebViewModelBase = BaseViewModel<
    WebViewModelState<WebViewStateContextProxy>,
    WebViewAction,
    WebViewStateContextProxy
>

/// Web view model interface, can be sendable because it is an actor (main one)
@MainActor public protocol WebViewModel: ViewModelInterface, ObservableObject
where State == WebViewModelState<WebViewStateContextProxy>,
      Action == WebViewAction,
      Context == WebViewStateContextProxy {

    // MARK: - navigation / policy (not pure sendAction)

    func decidePolicy(
        _ navigationAction: NavigationActionable,
        _ decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) async
    func decidePolicy(
        _ navigationAction: NavigationActionable
    ) async -> WKNavigationActionPolicy
    func updateTabPreview(_ screenshot: Data?) async

    // MARK: - public properties

    var nativeAppDomainNameString: String? { get }
    var configuration: WKWebViewConfiguration { get }
    var host: CottonBase.Host { get }
    var currentURL: URL? { get }
    var settings: Site.Settings { get }
    var urlInfo: URLInfo { get }
    /// Only for SwiftUI check to avoid handling of view updates
    var isResetable: Bool { get }

    /// Whether DNS-over-HTTPS is currently enabled (for building load requests from domain state).
    var isDohEnabled: Bool { get async }

    /// Returns `true` when `url` should be opened outside the web view (tel, mailto, Maps, App Store, …).
    func shouldOpenInExternalApp(_ url: URL) -> Bool

    // MARK: - navigation delegate wiring

    /// Site navigation delegate property should allow to set it later, e.g. in case of SwiftUI mode (e.g. with ToolbarViewModel)
    var siteNavigation: SiteExternalNavigationDelegate? { get set }
}
