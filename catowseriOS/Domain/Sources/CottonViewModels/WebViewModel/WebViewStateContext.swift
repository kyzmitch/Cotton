//
//  WebViewStateContext.swift
//  CottonViewModels
//
//  Copyright © 2026 Cotton (Catowser). All rights reserved.
//

import Foundation
import CottonBase
import CottonPlugins
import ViewModelKit
import WebKit

/// Side-effect surface for WebView domain transitions without exposing `WebViewModelImpl`.
@MainActor public protocol WebViewStateContext: StateContext {
    var pluginsSource: any JSPluginsSource { get }
    var isDohEnabled: Bool { get async }
    func allowNativeAppRedirects() async -> Bool
    func nativeApp(for host: CottonBase.Host) -> String?

    /// Legacy dual-write of view loading commands during cutover.
    func emit(_ loadingAction: WebPageLoadingAction)

    func resolveDomainName(_ originalURL: URL) async throws -> URL
    func remember(host: CottonBase.Host) async
    func replaceSelectedTab(with site: Site) async throws
    func enablePlugins(
        on subject: JavaScriptEvaluateble,
        context host: CottonBase.Host,
        jsEnabled: Bool
    )
    func injectPlugins(
        _ program: any JSPluginsProgram,
        into configuration: WKWebViewConfiguration,
        context host: CottonBase.Host,
        canInject: Bool
    )
    var webViewConfiguration: WKWebViewConfiguration { get }
}

/// Proxy that hides the view model implementation from the transition strategy.
public final class WebViewStateContextProxy: WebViewStateContext {
    private let subject: any WebViewStateContext

    init(subject: any WebViewStateContext) {
        self.subject = subject
    }

    public var pluginsSource: any JSPluginsSource { subject.pluginsSource }

    public var isDohEnabled: Bool {
        get async { await subject.isDohEnabled }
    }

    public func allowNativeAppRedirects() async -> Bool {
        await subject.allowNativeAppRedirects()
    }

    public func nativeApp(for host: CottonBase.Host) -> String? {
        subject.nativeApp(for: host)
    }

    public func emit(_ loadingAction: WebPageLoadingAction) {
        subject.emit(loadingAction)
    }

    public func resolveDomainName(_ originalURL: URL) async throws -> URL {
        try await subject.resolveDomainName(originalURL)
    }

    public func remember(host: CottonBase.Host) async {
        await subject.remember(host: host)
    }

    public func replaceSelectedTab(with site: Site) async throws {
        try await subject.replaceSelectedTab(with: site)
    }

    public func enablePlugins(
        on subjectJS: JavaScriptEvaluateble,
        context host: CottonBase.Host,
        jsEnabled: Bool
    ) {
        subject.enablePlugins(on: subjectJS, context: host, jsEnabled: jsEnabled)
    }

    public func injectPlugins(
        _ program: any JSPluginsProgram,
        into configuration: WKWebViewConfiguration,
        context host: CottonBase.Host,
        canInject: Bool
    ) {
        subject.injectPlugins(program, into: configuration, context: host, canInject: canInject)
    }

    public var webViewConfiguration: WKWebViewConfiguration {
        subject.webViewConfiguration
    }
}
