//
//  WebViewController+WebViewNavigatable.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/1/20.
//  Copyright © 2020 Cotton (former Catowser). All rights reserved.
//

import WebKit
import CottonBase
import CottonViewModels

// MARK: - Allow users of this delegate to control webview navigation

extension WebViewController: WebViewNavigatable {
    var canGoBack: Bool {
        guard let nonNilValue = webView else {
            return false
        }
        return isViewLoaded ? nonNilValue.canGoBack : false
    }

    var canGoForward: Bool {
        guard let nonNilValue = webView else {
            return false
        }
        return isViewLoaded ? nonNilValue.canGoForward : false
    }

    func goForward() {
        guard isViewLoaded else { return }
        viewModel.siteNavigation?.provisionalNavigationDidStart()
        viewModel.sendAction(.goForward) { result in
            if case .failure(let error) = result {
                print("Wrong state on go Forward action: \(error.localizedDescription)")
            }
        }
        _ = webView?.goForward()
    }

    func goBack() {
        guard isViewLoaded else { return }
        viewModel.siteNavigation?.provisionalNavigationDidStart()
        viewModel.sendAction(.goBack) { result in
            if case .failure(let error) = result {
                print("Wrong state on go Back action: \(error.localizedDescription)")
            }
        }
        _ = webView?.goBack()
    }

    func reload() {
        guard isViewLoaded else { return }
        viewModel.siteNavigation?.provisionalNavigationDidStart()
        viewModel.sendAction(.reload) { result in
            if case .failure(let error) = result {
                print("Wrong state on re-load action: \(error.localizedDescription)")
            }
        }
        _ = webView?.reload()
    }

    func enableJavaScript(_ enabled: Bool, for host: Host) {
        guard viewModel.host == host, let jsSubject = webView else {
            return
        }
        viewModel.sendAction(.changeJavaScript(jsSubject, enabled)) { result in
            if case .failure(let error) = result {
                print("Wrong state on JS change action: \(error.localizedDescription)")
            }
        }
    }

    var host: Host {
        viewModel.host
    }

    var siteSettings: Site.Settings {
        viewModel.settings
    }

    var url: URL? {
        viewModel.currentURL
    }
}
