//
//  WebViewController+SiteNavigationDelegate.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/1/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import WebKit

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
        externalNavigationDelegate?.didStartProvisionalNavigation()
        _ = webView.goForward()
    }

    func goBack() {
        guard isViewLoaded else { return }
        externalNavigationDelegate?.didStartProvisionalNavigation()
        _ = webView.goBack()
    }

    func reload() {
        guard isViewLoaded else { return }
        externalNavigationDelegate?.didStartProvisionalNavigation()
        _ = webView.reload()
    }
    
    /// Not only navigation of webview can be controlled, also, it's possible to show site menu,
    /// but to show it, the user of delegate shold know site info which is stored in webview holder.
    func openTabMenu(from sourceView: UIView, and sourceRect: CGRect) {
        externalNavigationDelegate?.openTabMenu(from: sourceView,
                                                and: sourceRect,
                                                for: urlInfo.host,
                                                siteSettings: siteSettings)
    }
    
    func reloadWithNewSettings(jsEnabled: Bool) {
        guard jsEnabled != siteSettings.isJsEnabled else {
            return
        }
        var mutableSettings = siteSettings
        mutableSettings.isJsEnabled = jsEnabled
        siteSettings = mutableSettings
        recreateWebView(forceRecreate: true)
        setupScripts(canLoadPlugins: siteSettings.canLoadPlugins)
        reattachWebViewObservers()
        internalLoad(url: urlInfo.url, enableDoH: dohUsed)
    }
}