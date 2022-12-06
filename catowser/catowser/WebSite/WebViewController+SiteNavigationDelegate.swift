//
//  WebViewController+SiteNavigationDelegate.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/1/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import WebKit
import CoreHttpKit

// MARK: - Allow users of this delegate to control webview navigation

extension WebViewController: SiteNavigationDelegate {
    var canGoBack: Bool {
        return isViewLoaded ? webView.canGoBack : false
    }

    var canGoForward: Bool {
        return isViewLoaded ? webView.canGoForward : false
    }

    func goForward() {
        guard isViewLoaded else { return }
        externalNavigationDelegate?.provisionalNavigationDidStart()
        viewModel.goForward()
        _ = webView.goForward()
    }

    func goBack() {
        guard isViewLoaded else { return }
        externalNavigationDelegate?.provisionalNavigationDidStart()
        viewModel.goBack()
        _ = webView.goBack()
    }

    func reload() {
        guard isViewLoaded else { return }
        externalNavigationDelegate?.provisionalNavigationDidStart()
        viewModel.reload()
        _ = webView.reload()
    }
    
    func enableJavaScript(_ enabled: Bool) {
        viewModel.setJavaScript(webView, enabled)
    }
}
