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
#if canImport(Combine)
import Combine
#endif

extension WKWebView: JavaScriptEvaluateble {}

final class WebViewController: BaseViewController {
    /// URL with info about ip address
    var urlInfo: HttpKit.URLIpInfo
    /// Configuration should be transferred from `Site`
    private var configuration: WKWebViewConfiguration
    ///
    var siteSettings: Site.Settings {
        didSet {
            configuration = siteSettings.webViewConfig
        }
    }
    /// JavaScript Plugins holder
    private(set) var pluginsFacade: WebViewJSPluginsFacade?
    /// Own navigation delegate
    private(set) weak var externalNavigationDelegate: SiteExternalNavigationDelegate?
    private var webViewObserversAdded = false
    private var loadingProgressObservation: NSKeyValueObservation?
    @available(iOS 13.0, *)
    private lazy var dnsRequestCancellable: AnyCancellable? = nil
    @available(iOS 13.0, *)
    private lazy var dnsFeatureChangeCancellable: AnyCancellable? = nil
    private var dnsRequestSubsciption: Disposable?
    private var dnsFeatureChangeSubsciption: Disposable?
    /// Http client to send DNS requests to unveal ip addresses of hosts to not show them, common for all web views
    private let dnsClient: GoogleDnsClient
    /// Was DoH used to load URL in WebView
    private(set) var dohUsed: Bool
    /// State of web view
    private var isWebViewLoaded: Bool = false
    /// Controller first appearance
    private var isFirstAppearance = true
    /// lazy loaded web view to use correct config
    lazy var webView: WKWebView = {
        webViewObserversAdded = false
        loadingProgressObservation?.invalidate()
        return createWebView(with: configuration)
    }()
    
    /// Need to use KVO for web view property because for some WKNavigations for
    /// not usual URLs like about:srcdoc the didCommit and didFinish won't be called
    /// and navigation button won't be updated based on state.
    private var canGoBackObservation: NSKeyValueObservation?
    private var canGoForwardObservation: NSKeyValueObservation?
    @available(iOS 13.0, *)
    private lazy var finalURLFetchCancellable: AnyCancellable? = nil
    private var finalURLFetchDisposable: Disposable?

    func load(url: URL, canLoadPlugins: Bool) {
        setupScripts(canLoadPlugins: canLoadPlugins)
        reattachWebViewObservers()
        dohUsed = FeatureManager.boolValue(of: .dnsOverHTTPSAvailable)
        internalLoad(url: url, enableDoH: dohUsed)
    }

    /// Reload by creating new webview
    func load(site: Site, canLoadPlugins: Bool) {
        urlInfo = site.urlInfo
        configuration = site.settings.webViewConfig
        
        recreateWebView()
        setupScripts(canLoadPlugins: canLoadPlugins)
        reattachWebViewObservers()
        dohUsed = FeatureManager.boolValue(of: .dnsOverHTTPSAvailable)
        internalLoad(url: urlInfo.url, enableDoH: dohUsed)
    }

    /**
     Constructs web view controller for specific site with set of plugins and navigation handler
     */
    init(_ site: Site,
         plugins: [CottonJSPlugin],
         externalNavigationDelegate: SiteExternalNavigationDelegate,
         dnsHttpClient: GoogleDnsClient) {
        self.externalNavigationDelegate = externalNavigationDelegate
        // Don't use `Site` model because  it contains some
        // properties which are not needed for web view
        urlInfo = site.urlInfo
        siteSettings = site.settings
        configuration = siteSettings.webViewConfig
        if siteSettings.canLoadPlugins {
            pluginsFacade = WebViewJSPluginsFacade(plugins)
        }
        dnsClient = dnsHttpClient
        dohUsed = false
        super.init(nibName: nil, bundle: nil)
        setupObservers()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        unsubscribe()
    }
    
    private func unsubscribe() {
        if #available(iOS 13.0, *) {
            dnsRequestCancellable?.cancel()
            finalURLFetchCancellable?.cancel()
            dnsFeatureChangeCancellable?.cancel()
        } else {
            dnsRequestSubsciption?.dispose()
            finalURLFetchDisposable?.dispose()
            dnsFeatureChangeSubsciption?.dispose()
        }
        loadingProgressObservation?.invalidate()
        canGoForwardObservation?.invalidate()
        canGoBackObservation?.invalidate()
    }
    
    override func loadView() {
        view = UIView(frame: .zero)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        load(url: urlInfo.url, canLoadPlugins: siteSettings.canLoadPlugins)
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isFirstAppearance {
            isFirstAppearance = false
        } else {
            // so, reuse of web view controller isn't ready
            // but probably not needed
            assertionFailure("Resubscribtion for web view isn't implemented yet")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        unsubscribe()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touchedView = touches.first?.view {
            if touchedView === webView {
                // to fix keypad for textfields on websites
                webView.becomeFirstResponder()
            }
        }
    }
    
    func handleLinkLoading(_ newURL: URL, _ webView: WKWebView) {
        if newURL.hasIPHost {
            urlInfo.updateURLForSameIP(url: newURL)
        } else if urlInfo.sameHost(with: newURL) {
            urlInfo.updateURLForSameHost(url: newURL)
        } else if let newURLinfo = HttpKit.URLIpInfo(newURL) {
            // if user moves from one host (search engine)
            // to different (specific website)
            // need to update host completely
            urlInfo = newURLinfo
        } else {
            assertionFailure("Impossible case with new URL: \(newURL)")
        }
        
        guard let site = Site(url: urlInfo.domainURL, settings: siteSettings) else {
            assertionFailure("Failed create site from URL")
            return
        }
        
        // you must inject re-enable plugins even if web view loaded page from same Host
        // and even if ip address is used instead of domain name
        pluginsFacade?.enablePlugins(for: webView, with: urlInfo.host)
        InMemoryDomainSearchProvider.shared.remember(domainName: urlInfo.host)
        
        do {
            try TabsListManager.shared.replaceSelected(tabContent: .site(site))
        } catch {
            print("\(#function) - failed to replace current tab")
        }
    }
    
    func recreateWebView(forceRecreate: Bool = false) {
        if !forceRecreate {
            guard !isWebViewLoaded else {
                return
            }
        }
        
        loadingProgressObservation?.invalidate()
        webViewObserversAdded = false
        
        webView.removeFromSuperview()
        webView = createWebView(with: configuration)
        view.addSubview(webView)
        
        webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func reattachWebViewObservers() {
        guard !webViewObserversAdded else {
            return
        }
        webViewObserversAdded = true
        addWebViewProgressObserver()
        addWebViewCanGoBackObserver()
        addWebViewCanGoForwardObserver()
    }
    
    func internalLoad(url: URL, enableDoH: Bool) {
        let needResolveHost = enableDoH && url.kitHost?.isDoHSupported ?? false
        guard needResolveHost && !url.hasIPHost else {
            let request = URLRequest(url: url)
            webView.load(request)
            return
        }
        
        if #available(iOS 13.0, *) {
            dnsRequestCancellable?.cancel()
            dnsRequestCancellable = dnsClient.resolvedDomainName(in: url)
            .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { (completion) in
                    switch completion {
                    case .failure(let dnsErr):
                        print("fail to resolve host with DNS: \(dnsErr.localizedDescription)")
                    default:
                        break
                    }
                }, receiveValue: { (finalURL) in
                    guard finalURL.hasIPHost else {
                        print("Alert - host wasn't replaced on IP address after operation")
                        return
                    }
                    self.urlInfo.ipAddress = finalURL.host
                    let request = URLRequest(url: finalURL)
                    self.webView.load(request)
                })
        } else {
            dnsRequestSubsciption?.dispose()
            dnsRequestSubsciption = dnsClient.rxResolvedDomainName(in: url)
                .start(on: UIScheduler())
                .startWithResult({ [weak self] (result) in
                    guard let self = self else {
                        return
                    }
                    guard case .success(let finalURL) = result else {
                        print("fail to resolve host with DNS")
                        return
                    }
                    
                    guard finalURL.hasIPHost else {
                        print("Alert - host wasn't replaced on IP address after operation")
                        return
                    }
                    self.urlInfo.ipAddress = finalURL.host
                    let request = URLRequest(url: finalURL)
                    self.webView.load(request)
                })
        }
    }
    
    func setupScripts(canLoadPlugins: Bool) {
        if canLoadPlugins {
            injectPlugins()
        } else {
            configuration.userContentController.removeAllUserScripts()
        }
    }
}

// MARK: - private functions

private extension WebViewController {
    func createWebView(with config: WKWebViewConfiguration) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = .white
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        
        return webView
    }
    
    func injectPlugins() {
        configuration.userContentController.removeAllUserScripts()
        // inject only for specific sites, to fix case
        // when instagram related plugin is injected to webview with google site
        pluginsFacade?.visit(configuration.userContentController)
    }
    
    func addWebViewProgressObserver() {
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
    
    func addWebViewCanGoBackObserver() {
        canGoBackObservation?.invalidate()
        canGoBackObservation = webView.observe(\.canGoBack, options: [.new]) { [weak self] (_, change) in
            guard let self = self else { return }
            guard let value = change.newValue else { return }
            self.externalNavigationDelegate?.didUpdateBackNavigation(to: value)
            self.updateNavigatedURL(self.webView)
        }
    }
    
    func addWebViewCanGoForwardObserver() {
        canGoForwardObservation?.invalidate()
        canGoForwardObservation = webView.observe(\.canGoForward, options: [.new]) { [weak self] (_, change) in
            guard let self = self else { return }
            guard let value = change.newValue else { return }
            self.externalNavigationDelegate?.didUpdateForwardNavigation(to: value)
        }
    }
    
    func updateNavigatedURL(_ webView: WKWebView) {
        if #available(iOS 13.0, *) {
            fetchFinalURLFromJS(webView)
        } else {
            rxFetchFinalURLFromJS(webView)
        }
    }
    
    @available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func fetchFinalURLFromJS(_ webView: WKWebView) {
        finalURLFetchCancellable?.cancel()
        finalURLFetchCancellable = webView.finalURLPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
                switch completion {
                case .failure(let finalURLError):
                    print("JS didn't return final url: \(finalURLError.localizedDescription)")
                default: break
                }
            }, receiveValue: { [weak self] (url) in
                self?.handleLinkLoading(url, webView)
            })
    }
    
    func rxFetchFinalURLFromJS(_ webView: WKWebView) {
        finalURLFetchDisposable?.dispose()
        finalURLFetchDisposable = webView.rxFinalURL()
            .observe(on: QueueScheduler.main)
            .startWithResult { [weak self] (result) in
                switch result {
                case .failure(let finalURLError):
                    print("JS didn't return final url: \(finalURLError.localizedDescription)")
                case .success(let url):
                    self?.handleLinkLoading(url, webView)
                }
        }
    }
    
    func handleDoHFeatureChange(_ needToUseDoH: Bool) {
        if needToUseDoH != dohUsed {
            dohUsed = needToUseDoH
            // maybe need to trigger UI webview reload state
            externalNavigationDelegate?.didStartProvisionalNavigation()
            if needToUseDoH && urlInfo.ipAddress != nil {
                let request = URLRequest(url: urlInfo.url)
                webView.load(request)
            } else {
                internalLoad(url: urlInfo.domainURL, enableDoH: needToUseDoH)
            }
        }
    }
    
    /// Call only once at init
    func setupObservers() {
        if #available(iOS 13.0, *) {
            dnsFeatureChangeCancellable = FeatureManager.featureChangesPublisher(for: .dnsOverHTTPSAvailable)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] (feature) in
                    let needToUseDoH = FeatureManager.boolValue(of: feature)
                    self?.handleDoHFeatureChange(needToUseDoH)
            }
        } else {
            dnsFeatureChangeSubsciption = FeatureManager.rxFeatureChanges(for: .dnsOverHTTPSAvailable)
                .observe(on: UIScheduler())
                .observeValues { [weak self] (feature) in
                    let needToUseDoH = FeatureManager.boolValue(of: feature)
                    self?.handleDoHFeatureChange(needToUseDoH)
            }
        }
        
    }
}
