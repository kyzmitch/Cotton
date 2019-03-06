//
//  WebViewController.swift
//  catowser
//
//  Created by Andrey Ermoshin on 27/09/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import UIKit
import SnapKit
import WebKit
import CoreBrowser

protocol SiteNavigationDelegate: class {
    var canGoBack: Bool { get }
    var canGoForward: Bool { get }

    func goForward()
    func goBack()
    func reload()
}

protocol SiteNavigationComponent {
    func updateSiteNavigator(to navigator: SiteNavigationDelegate)
    /// Reloads state of UI components
    func reloadNavigationElements()
}

final class WebViewController: BaseViewController {
    
    var site: Site {
        didSet {
            let request = URLRequest(url: site.url)
            webView.load(request)
        }
    }

    init(_ site: Site) {
        self.site = site
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let webView: WKWebView = {
        let webView = WKWebView()
        webView.backgroundColor = .black
        
        return webView
    }()
    
    override func loadView() {
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        let request = URLRequest(url: site.url)
        webView.load(request)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // TODO: don't remember why it is needed
        if let touchedView = touches.first?.view {
            if touchedView === webView {
                webView.becomeFirstResponder()
            }
        }
    }
}

fileprivate extension WebViewController {
    func isAppleMapsURL(_ url: URL) -> Bool {
        if url.scheme == "http" || url.scheme == "https" {
            if url.host == "maps.apple.com" && url.query != nil {
                return true
            }
        }
        return false
    }

    func isStoreURL(_ url: URL) -> Bool {
        if url.scheme == "http" || url.scheme == "https" || url.scheme == "itms-apps" {
            if url.host == "itunes.apple.com" {
                return true
            }
        }
        return false
    }
}

extension WebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        if url.scheme == "tel" || url.scheme == "facetime" || url.scheme == "facetime-audio" {
            UIApplication.shared.open(url, options: [:])
            decisionHandler(.cancel)
            return
        }

        if isAppleMapsURL(url) {
            UIApplication.shared.open(url, options: [:])
            decisionHandler(.cancel)
            return
        }

        if isStoreURL(url) {
            UIApplication.shared.open(url, options: [:])
            decisionHandler(.cancel)
            return
        }

        if url.scheme == "mailto" {
            UIApplication.shared.open(url, options: [:])
            decisionHandler(.cancel)
            return
        }

        if ["http", "https"].contains(url.scheme) {
            decisionHandler(.allow)
            return
        }

        decisionHandler(.cancel)
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        guard let webViewUrl = webView.url else {
            print("web view without url")
            return
        }
        guard let currentTab = try? TabsListManager.shared.selectedTab() else {
            fatalError("opening a link without current tab")
        }

        // check if it is same site
        guard case let .site(currentSite) = currentTab.contentType, currentSite.url != webViewUrl else {
            return
        }

        let site = Site(url: webViewUrl)
        var updatedTab = currentTab
        updatedTab.contentType = .site(site)
        do {
            try TabsListManager.shared.replaceSelectedTab(with: updatedTab)
        } catch {
            print("\(#function) - failed to replace current tab")
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
    }
}

extension WebViewController: WKNavigationDelegate {
    
}

extension WebViewController: SiteNavigationDelegate {
    var canGoBack: Bool {
        return webView.canGoBack
    }

    var canGoForward: Bool {
        return webView.canGoForward
    }

    func goForward() {
        _ = webView.goForward()
    }

    func goBack() {
        _ = webView.goBack()
    }

    func reload() {
        _ = webView.reload()
    }
}
