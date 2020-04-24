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

extension WKWebView: JavaScriptEvaluateble {}

final class WebViewController: BaseViewController {
    /// URL with info about ip address
    var urlInfo: HttpKit.URLIpInfo
    /// Configuration should be transferred from `Site`
    private var configuration: WKWebViewConfiguration
    /// JavaScript Plugins holder
    private(set) var pluginsFacade: WebViewJSPluginsFacade?
    /// Own navigation delegate
    private(set) weak var externalNavigationDelegate: SiteExternalNavigationDelegate?
    private var webViewProgressObserverAdded = false
    private var loadingProgressObservation: NSKeyValueObservation?
    private var dnsRequestSubsciption: Disposable?
    /// Http client to send DNS requests to unveal ip addresses of hosts to not show them, common for all web views
    private static let dnsClient: HttpKit.Client<HttpKit.GoogleDnsServer> = {
        let server = HttpKit.GoogleDnsServer()
        return .init(server: server)
    }()
    private var isWebViewLoaded: Bool = false
    /// lazy loaded web view to use correct config
    private lazy var webView: WKWebView = {
        webViewProgressObserverAdded = false
        loadingProgressObservation?.invalidate()
        return createWebView(with: configuration)
    }()

    func load(url: URL, canLoadPlugins: Bool = true) {
        // TODO: actually this func is called using URLIpInfo, so, maybe no need to update it
        guard let info = HttpKit.URLIpInfo(url) else {
            print("Fail create url info for raw URL")
            return
        }
        urlInfo = info
        setupScripts(canLoadPlugins: canLoadPlugins)
        addWebViewProgressObserver()
        internalLoad(url: url)
    }

    /// Reload by creating new webview
    func load(site: Site, canLoadPlugins: Bool = true) {
        urlInfo = site.url
        configuration = site.webViewConfig
        
        if isWebViewLoaded {
            loadingProgressObservation?.invalidate()
            webViewProgressObserverAdded = false
            
            webView.removeFromSuperview()
            webView = createWebView(with: configuration)
            view.addSubview(webView)
            webView.snp.makeConstraints { (maker) in
                maker.leading.trailing.top.bottom.equalTo(view)
            }
        }
        
        setupScripts(canLoadPlugins: canLoadPlugins)
        addWebViewProgressObserver()
        internalLoad(url: urlInfo.url)
    }

    /**
     Constructs web view controller for specific site with set of plugins and navigation handler
     */
    init(_ site: Site,
         plugins: [CottonJSPlugin],
         externalNavigationDelegate: SiteExternalNavigationDelegate) {
        self.externalNavigationDelegate = externalNavigationDelegate
        urlInfo = site.url
        configuration = site.webViewConfig
        if site.canLoadPlugins {
            pluginsFacade = WebViewJSPluginsFacade(plugins)
        }

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        if let touchedView = touches.first?.view {
            if touchedView === webView {
                // to fix keypad for textfields on websites
                webView.becomeFirstResponder()
            }
        }
    }
}

private extension WebViewController {
    func setupScripts(canLoadPlugins: Bool) {
        if canLoadPlugins {
            injectPlugins()
        } else {
            configuration.userContentController.removeAllUserScripts()
        }
    }
    
    func createWebView(with config: WKWebViewConfiguration) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.backgroundColor = .white
        webView.navigationDelegate = self
        return webView
    }
    
    func injectPlugins() {
        configuration.userContentController.removeAllUserScripts()
        // inject only for specific sites, to fix case
        // when instagram related plugin is injected to webview with google site
        pluginsFacade?.visit(configuration.userContentController)
    }
    
    func addWebViewProgressObserver() {
        if !webViewProgressObserverAdded {
            webViewProgressObserverAdded = true
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
    
    func internalLoad(url: URL) {
        guard FeatureManager.boolValue(of: .dnsOverHTTPSAvailable) else {
            let request = URLRequest(url: url)
            webView.load(request)
            return
        }
        
        dnsRequestSubsciption?.dispose()
        dnsRequestSubsciption = url.rxReplaceHostWithIPAddress(using: WebViewController.dnsClient)
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
