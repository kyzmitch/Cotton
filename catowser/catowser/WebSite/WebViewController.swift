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
import HttpKit
import ReactiveSwift

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
    func displayProgress(_ progress: Double)
    func showProgress(_ show: Bool)
    func updateTabPreview(_ screenshot: UIImage)
}

protocol SiteNavigationComponent: class {
    /// Use `nil` to tell that navigation actions should be disabled
    var siteNavigator: SiteNavigationDelegate? { get set }
    /// Reloads state of UI components
    func reloadNavigationElements(_ withSite: Bool, downloadsAvailable: Bool)
}

extension WKWebView: JavaScriptEvaluateble {}

struct URLInfo {
    let url: URL
    var ipAddress: String?
    
    init(_ url: URL) {
        self.url = url
        ipAddress = nil
    }
}

final class WebViewController: BaseViewController {
    
    private(set) var urlInfo: URLInfo

    /// Configuration should be transferred from `Site`
    private var configuration: WKWebViewConfiguration

    private var pluginsFacade: WebViewJSPluginsFacade?

    private weak var externalNavigationDelegate: SiteExternalNavigationDelegate?
    
    private var webViewProgressObserverAdded = false
    
    private var loadingProgressObservation: NSKeyValueObservation?
    
    private var dnsRequestSubsciption: Disposable?
    
    private static let dnsClient: HttpKit.Client<HttpKit.GoogleDnsServer> = {
        let server = HttpKit.GoogleDnsServer()
        return .init(server: server)
    }()
    
    private func internalLoad(url: URL) {
        dnsRequestSubsciption?.dispose()
        dnsRequestSubsciption = url.rxHttpHost
            .flatMapError({ (dnsErr) -> SignalProducer<String, HttpKit.HttpError> in
                print("Host error: \(dnsErr.localizedDescription)")
                return .init(error: .failedConstructRequestParameters)
            })
            .flatMap(.latest, { (host) -> HttpKit.GDNSjsonProducer in
                return WebViewController.dnsClient.getIPaddress(ofDomain: host)
            })
            .flatMapError({ (kitErr) -> SignalProducer<HttpKit.GoogleDNSOverJSONResponse, DnsError> in
                print("Http error: \(kitErr.localizedDescription)")
                return .init(error: .httpError(kitErr))
            })
            .flatMap(.latest, { [weak self] (response) -> UrlConvertProducer in
                guard let self = self else {
                    return .init(error: .zombieSelf)
                }
                var mutableInfo = self.urlInfo
                mutableInfo.ipAddress = response.ipAddress
                self.urlInfo = mutableInfo
                return url.updateHost(with: response.ipAddress)
            })
            .start(on: UIScheduler())
            .startWithResult({ [weak self] (result) in
                guard let self = self else {
                    return
                }
                guard case .success(let finalURL) = result else {
                    return
                }
                
                let request = URLRequest(url: finalURL)
                self.webView.load(request)
            })
    }

    func load(url: URL, canLoadPlugins: Bool = true) {
        urlInfo = URLInfo(url)

        if canLoadPlugins {
            injectPlugins()
        } else if !canLoadPlugins {
            configuration.userContentController.removeAllUserScripts()
        }

        addWebViewProgressObserver()
        internalLoad(url: url)
    }

    /// Reload by creating new webview
    func load(site: Site, canLoadPlugins: Bool = true) {
        urlInfo = URLInfo(site.url)
        configuration = site.webViewConfig
        
        if isWebViewLoaded {
            // legacy KVO
            // webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
            loadingProgressObservation?.invalidate()
            webViewProgressObserverAdded = false
            
            webView.removeFromSuperview()
            webView = createWebView(with: configuration)
            view.addSubview(webView)
            webView.snp.makeConstraints { (maker) in
                maker.leading.trailing.top.bottom.equalTo(view)
            }
        }
        
        if canLoadPlugins { injectPlugins() }
        
        addWebViewProgressObserver()
        internalLoad(url: urlInfo.url)
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

    init(_ site: Site, plugins: [CottonJSPlugin], externalNavigationDelegate: SiteExternalNavigationDelegate) {
        self.externalNavigationDelegate = externalNavigationDelegate
        urlInfo = URLInfo(site.url)
        configuration = site.webViewConfig
        if site.canLoadPlugins {
            pluginsFacade = WebViewJSPluginsFacade(plugins)
        }

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isWebViewLoaded: Bool = false

    private lazy var webView: WKWebView = {
        webViewProgressObserverAdded = false
        loadingProgressObservation?.invalidate()
        return createWebView(with: configuration)
    }()
    
    private func createWebView(with config: WKWebViewConfiguration) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = .white
        webView.navigationDelegate = self
        return webView
    }
    
    override func loadView() {
        view = UIView(frame: .zero)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        load(url: urlInfo.url)
        // try create web view only after creating
        view.addSubview(webView)
        isWebViewLoaded = true
        webView.navigationDelegate = self
        webView.uiDelegate = self
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

private extension WebViewController {
    func addWebViewProgressObserver() {
        if !webViewProgressObserverAdded {
            webViewProgressObserverAdded = true
            // legacy KVO was left for comparison with new API
            /*
            webView.addObserver(self,
                                forKeyPath: #keyPath(WKWebView.estimatedProgress),
                                options: .new,
                                context: nil)
             */
            
            // swiftlint:disable:next line_length
            // https://github.com/ole/whats-new-in-swift-4/blob/master/Whats-new-in-Swift-4.playground/Pages/Key%20paths.xcplaygroundpage/Contents.swift#L53-L95
            
            loadingProgressObservation?.invalidate()
            loadingProgressObservation = webView.observe(\.estimatedProgress,
                                                         options: [.new]) { [weak self] (_, change) in
                guard let self = self else { return }
                guard let value = change.newValue else { return }
                self.externalNavigationDelegate?.displayProgress(value)
            }
        }
    }
}

fileprivate extension WebViewController {
    func handleNavigationCommit(_ wkView: WKWebView) {
        guard let webViewUrl = wkView.url else {
            print("web view without url")
            return
        }

        guard let site = Site(url: webViewUrl) else {
            assertionFailure("failed create site from URL")
            return
        }
        
        // you must inject re-enable plugins even if web view loaded page from same Host
        
        pluginsFacade?.enablePlugins(for: wkView, with: site.host)
        InMemoryDomainSearchProvider.shared.rememberDomain(name: site.host)
        
        do {
            try TabsListManager.shared.replaceSelected(tabContent: .site(site))
        } catch {
            print("\(#function) - failed to replace current tab")
        }
    }
}

extension WebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        return nil
    }
}

// MARK: - WKNavigationDelegate

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        if !urlInfo.url.hasIPHost,
            HostsComparator(urlInfo.url, url)?.shouldCancelRedirect ?? false {
            decisionHandler(.cancel)
            return
        }
        
        if url.scheme == "about" {
            // This will handle about:blank from youtube.
            // sometimes url can be unexpected
            // this one is when you tap on some youtube video
            // when you was browsing youtube
            
            if let mainURL = navigationAction.request.mainDocumentURL,
                let comparator = HostsComparator(urlInfo.url, mainURL) {
                if comparator.isPendingSame {
                    decisionHandler(.allow)
                } else {
                    decisionHandler(.cancel)
                }
            } else {
                // don't show progress for requests to about scheme
                decisionHandler(.allow)
            }
            return
        }
        
        if url.scheme == "tel" || url.scheme == "facetime" || url.scheme == "facetime-audio" {
            UIApplication.shared.open(url, options: [:])
            decisionHandler(.cancel)
            return
        }

        if url.isAppleMapsURL {
            UIApplication.shared.open(url, options: [:])
            decisionHandler(.cancel)
            return
        }

        if url.isStoreURL {
            UIApplication.shared.open(url, options: [:])
            decisionHandler(.cancel)
            return
        }

        if url.scheme == "mailto" {
            UIApplication.shared.open(url, options: [:])
            decisionHandler(.cancel)
            return
        }

        if !url.hasIPHost,
            let newHost = url.host,
            let checker = try? DomainNativeAppChecker(url: newHost) {
            externalNavigationDelegate?.didOpenSiteWith(appName: checker.correspondingDomain)

            let ignoreAppRawValue = WKNavigationActionPolicy.allow.rawValue + 2
            guard WKNavigationActionPolicy(rawValue: ignoreAppRawValue) != nil else {
                decisionHandler(.allow)
                return
            }
            // swiftlint:disable:next force_unwrapping
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
        externalNavigationDelegate?.showProgress(true)
        handleNavigationCommit(webView)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        externalNavigationDelegate?.showProgress(false)
        if let actualHost = urlInfo.url.host {
            pluginsFacade?.enablePlugins(for: webView, with: actualHost)
        }
        
        let snapshotConfig = WKSnapshotConfiguration()
        let w = webView.bounds.size.width
        let h = webView.bounds.size.height
        snapshotConfig.rect = CGRect(x: 0, y: 0, width: w, height: h)
        snapshotConfig.snapshotWidth = 256
        webView.takeSnapshot(with: snapshotConfig) { [weak self] (image, error) in
            switch (image, error) {
            case (_, let err?):
                print("failed to take a screenshot \(err)")
            case (let img?, _):
                self?.externalNavigationDelegate?.updateTabPreview(img)
            case (.none, .none):
                print("failed to take a screenshot")
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Fail to load URL request: \(error.localizedDescription)")
        externalNavigationDelegate?.showProgress(false)
    }
    
    func webView(_ webView: WKWebView,
                 didReceive challenge: URLAuthenticationChallenge,
                 completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        let host = challenge.protectionSpace.host
        guard host == urlInfo.url.host || host == urlInfo.ipAddress else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        // https://developer.apple.com/documentation/foundation/url_loading_system/handling_an_authentication_challenge/performing_manual_server_trust_authentication
        
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        if let initialHost = urlInfo.url.host, serverTrust.checkValidity(ofHost: initialHost) {
            let credential = URLCredential(trust: serverTrust)
            completionHandler(.useCredential, credential)
        } else {
            // Show a UI here warning the user the server credentials are
            // invalid, and cancel the load.
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
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
