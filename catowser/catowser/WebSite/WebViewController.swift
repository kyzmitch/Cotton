//
//  WebViewController.swift
//  catowser
//
//  Created by Andrey Ermoshin on 27/09/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import UIKit
import WebKit
import CoreBrowser
import JSPlugins

protocol CottonPluginsProvider: class {
    func defaultPlugins() -> [CottonJSPlugin]
}

protocol SiteNavigationDelegate: class {
    var canGoBack: Bool { get }
    var canGoForward: Bool { get }

    func goForward()
    func goBack()
    func reload()
}

protocol SiteExternalNavigationDelegate: class {
    func didStartProvisionalNavigation()
    func didOpenSiteWith(appName: String)
}

protocol SiteNavigationComponent {
    func updateSiteNavigator(to navigator: SiteNavigationDelegate?)
    /// Reloads state of UI components
    func reloadNavigationElements(_ withSite: Bool, downloadsAvailable: Bool)
}

extension WKWebView: JavaScriptEvaluateble {}

final class WebViewController: BaseViewController {
    
    private(set) var currentUrl: URL

    /// Configuration should be transferred from `Site`
    private var configuration: WKWebViewConfiguration

    private var pluginsFacade: WebViewJSPluginsFacade?

    private weak var externalNavigationDelegate: SiteExternalNavigationDelegate?

    fileprivate let igSiteName = "instagram.com"

    func load(_ url: URL, canLoadPlugins: Bool = true) {
        currentUrl = url

        if canLoadPlugins {
            injectPlugins()
        } else if !canLoadPlugins {
            configuration.userContentController.removeAllUserScripts()
        }

        let request = URLRequest(url: url)
        webView.load(request)
    }

    /// Reload by creating new webview
    func load(site: Site, canLoadPlugins: Bool = true) {
        currentUrl = site.url
        configuration = site.webViewConfig
        
        if isWebViewLoaded {
            webView.removeFromSuperview()
            webView = WebViewController.createWebView(with: configuration)
            view.addSubview(webView)
            webView.snp.makeConstraints { (maker) in
                maker.leading.trailing.top.bottom.equalTo(view)
            }
        }
        
        if canLoadPlugins { injectPlugins() }
        
        let request = URLRequest(url: currentUrl)
        webView.load(request)
    }

    private func injectPlugins() {
        configuration.userContentController.removeAllUserScripts()
        // inject only for specific sites, to fix case
        // then instagram related plugin is injected to google site
        guard let facade = pluginsFacade else {
            return
        }
        facade.visit(configuration.userContentController)
    }

    init(_ site: Site, pluginsProvider: CottonPluginsProvider, externalNavigationDelegate: SiteExternalNavigationDelegate) {
        self.externalNavigationDelegate = externalNavigationDelegate
        currentUrl = site.url
        configuration = site.webViewConfig
        if site.canLoadPlugins {
            pluginsFacade = WebViewJSPluginsFacade(pluginsProvider.defaultPlugins())
        }

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isWebViewLoaded: Bool = false

    private lazy var webView: WKWebView = {
        return WebViewController.createWebView(with: configuration)
    }()
    
    private static func createWebView(with config: WKWebViewConfiguration) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = .white
        return webView
    }
    
    override func loadView() {
        view = UIView(frame: .zero)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        load(currentUrl)
        // try create web view only after creating
        view.addSubview(webView)
        isWebViewLoaded = true
        webView.navigationDelegate = self

        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
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

extension WebViewController: WKNavigationDelegate {
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

        if url.absoluteString.contains(igSiteName) {
            externalNavigationDelegate?.didOpenSiteWith(appName: igSiteName)

            let ignoreAppRawValue = WKNavigationActionPolicy.allow.rawValue + 2
            guard let _ = WKNavigationActionPolicy(rawValue: ignoreAppRawValue) else {
                decisionHandler(.allow)
                return
            }
            decisionHandler(WKNavigationActionPolicy(rawValue: ignoreAppRawValue)!)
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

        currentUrl = webViewUrl
        let site: Site = .init(url: webViewUrl)
        // enabling plugin works here for instagram, but not for t4 site
        pluginsFacade?.enablePlugins(for: webView, with: currentUrl.host)

        if let host = currentUrl.host {
            InMemoryDomainSearchProvider.shared.rememberDomain(name: host)
        }

        do {
            try TabsListManager.shared.replaceSelected(tabContent: .site(site))
        } catch {
            print("\(#function) - failed to replace current tab")
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        pluginsFacade?.enablePlugins(for: webView, with: currentUrl.host)
    }
}

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
}
