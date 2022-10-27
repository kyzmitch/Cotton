//
//  MainBrowserViewController.swift
//  catowser
//
//  Created by Andrey Ermoshin on 27/09/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import UIKit
import ReactiveSwift
import CoreBrowser
import FeaturesFlagsKit
import JSPlugins
import CoreHttpKit
import CoreCatowser

/// An interface for component which suppose to render tabs
///
/// Class protocol is used because object gonna be stored by `weak` ref
/// `AnyObject` is new name for it, but will use old one to find when XCode
/// will start mark it as deprecated.
/// https://forums.swift.org/t/class-only-protocols-class-vs-anyobject/11507/4
protocol TabRendererInterface: AnyViewController {
    func open(tabContent: Tab.ContentType)
}

final class MainBrowserViewController: BaseViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    /// Router and layout handler for supplementary views.
    private var linksRouter: MainRouter!

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Tabs list without previews. Needed only for tablets or landscape mode.
    private lazy var tabsViewController: TabsViewController = {
        let viewController = TabsViewController()
        return viewController
    }()

    /// The view controller to manage blank tab, possibly will be enhaced
    /// to support favorite sites list.
    private let blankWebPageController = BlankWebPageViewController()

    private let topSitesController: AnyViewController & TopSitesInterface = TopSitesViewController.newFromNib()

    /// The view needed to hold tab content like WebView or favorites table view.
    private let containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        return v
    }()
    
    /// The view required to demonstrait web content load process.
    private let webLoadProgressView: UIProgressView = {
        let v = UIProgressView(progressViewStyle: .default)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    /// The controller for toolbar buttons. Used only for compact sizes/smartphones.
    private lazy var toolbarViewController: WebBrowserToolbarController = {
        let router = ToolbarRouter(presenter: self)
        let toolbar = WebBrowserToolbarController(router: router,
                                                  downloadDelegate: linksRouter,
                                                  globalSettingsDelegate: linksRouter)
        return toolbar
    }()

    /// View to make color under toolbar is the same on iPhone x without home button
    private lazy var underToolbarView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        ThemeProvider.shared.setupUnderToolbar(v)
        return v
    }()

    private lazy var underLinkTagsView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        ThemeProvider.shared.setupUnderLinkTags(v)
        return v
    }()

    var mKeyboardHeight: CGFloat?

    /// The current holder for WebView (controller) if browser has at least one
    private weak var currentWebViewController: AnyViewController?

    private var disposables = [Disposable?]()

    private let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad ? true : false
    /// Not a constant because can't be initialized in init
    private var jsPluginsBuilder: (any JSPluginsSource)?

    /// Not initialized, will be initialized after `TabsListManager`
    /// during tab opening. Used only during tab opening for optimization
    private lazy var previousTabContent: Tab.ContentType = FeatureManager.tabDefaultContentValue().contentType
    
    override func loadView() {
        // Your custom implementation of this method should not call super.
        view = UIView()
        
        // In that method, create your view hierarchy programmatically and assign
        // the root view of that hierarchy to the view controller’s view property.
        
        if isPad {
            add(asChildViewController: tabsViewController, to: view)
        }

        linksRouter = MainRouter(viewController: self)

        add(asChildViewController: linksRouter.searchBarController.viewController, to: view)
        view.addSubview(webLoadProgressView)
        view.addSubview(containerView)

        if isPad {
            // no need to add files greed as a child
            // will try to show as popover

            view.addSubview(underLinkTagsView)
            add(asChildViewController: linksRouter.linkTagsController.viewController, to: view)
        } else {
            add(asChildViewController: linksRouter.filesGreedController.viewController, to: view)
            // should be added before iPhone toolbar
            add(asChildViewController: linksRouter.linkTagsController.viewController, to: view)
            add(asChildViewController: toolbarViewController, to: view)
            // Need to not add it if it is not iPhone without home button
            view.addSubview(underToolbarView)
        }
    }
    
    private func setupTabletConstraints(_ searchView: UIView, _ tagsView: UIView) {
        let tabsView: UIView = tabsViewController.view
        tabsView.translatesAutoresizingMaskIntoConstraints = false
        // https://github.com/SnapKit/SnapKit/issues/448
        // https://developer.apple.com/documentation/uikit/uiviewcontroller/1621367-toplayoutguide
        // https://developer.apple.com/documentation/uikit/uiview/2891102-safearealayoutguide
        if #available(iOS 11, *) {
            tabsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            tabsView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        }
        tabsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tabsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tabsView.heightAnchor.constraint(equalToConstant: .tabHeight).isActive = true
        
        searchView.topAnchor.constraint(equalTo: tabsView.bottomAnchor).isActive = true
        searchView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        searchView.heightAnchor.constraint(equalToConstant: .searchViewHeight).isActive = true
        
        let sbViewBottomAnchor = searchView.bottomAnchor
        webLoadProgressView.topAnchor.constraint(equalTo: sbViewBottomAnchor).isActive = true
        
        // Need to have not simple view controller view but container view
        // to have ability to insert to it and show view controller with
        // bookmarks in case if search bar has no any address entered or
        // webpage controller with web view if some address entered in search bar
        containerView.topAnchor.constraint(equalTo: webLoadProgressView.bottomAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        underLinkTagsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        underLinkTagsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        let dummyViewHeight: CGFloat = .safeAreaBottomMargin
        let linksHConstraint = underLinkTagsView.heightAnchor.constraint(equalToConstant: dummyViewHeight)
        linksRouter.underLinksViewHeightConstraint = linksHConstraint
        linksRouter.underLinksViewHeightConstraint?.isActive = true

        let bottomMargin: CGFloat = dummyViewHeight + .linkTagsHeight
        linksRouter.hiddenTagsConstraint = underLinkTagsView.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                                                     constant: bottomMargin)
        linksRouter.showedTagsConstraint = underLinkTagsView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let tagsBottom = tagsView.bottomAnchor
        tagsBottom.constraint(equalTo: underLinkTagsView.topAnchor).isActive = true
    }
    
    private func setupPhoneConstraints(_ searchView: UIView, _ tagsView: UIView) {
        if #available(iOS 11, *) {
            searchView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            searchView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        }
        searchView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        searchView.heightAnchor.constraint(equalToConstant: .searchViewHeight).isActive = true
        
        webLoadProgressView.topAnchor.constraint(equalTo: searchView.bottomAnchor).isActive = true
        
        let toolbarView: UIView = toolbarViewController.view
        toolbarView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.topAnchor.constraint(equalTo: webLoadProgressView.bottomAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: toolbarView.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        toolbarView.topAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        toolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        toolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        toolbarView.heightAnchor.constraint(equalToConstant: .tabBarHeight).isActive = true
        if #available(iOS 11, *) {
            toolbarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            toolbarView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        }
        
        underToolbarView.topAnchor.constraint(equalTo: toolbarView.bottomAnchor).isActive = true
        underToolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        underToolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        underToolbarView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        linksRouter.hiddenTagsConstraint = tagsView.bottomAnchor.constraint(equalTo: toolbarView.topAnchor,
                                                                            constant: .linkTagsHeight)
        linksRouter.showedTagsConstraint = tagsView.bottomAnchor.constraint(equalTo: toolbarView.topAnchor)
    }
    
    private func setupObservers() {
        jsPluginsBuilder = JSPluginsBuilder(baseDelegate: self, instagramDelegate: self)
        
        let disposeB = NotificationCenter.default.reactive
            .notifications(forName: UIResponder.keyboardWillHideNotification)
            .observe(on: UIScheduler())
            .observeValues { [weak self] (notification) in
                self?.keyboardWillHideClosure()(notification)
        }

        let disposeA = NotificationCenter.default.reactive
            .notifications(forName: UIResponder.keyboardDidChangeFrameNotification)
            .observe(on: UIScheduler())
            .observeValues { [weak self] notification in
                self?.keyboardWillChangeFrameClosure()(notification)
        }

        disposables.append(disposeB)
        disposables.append(disposeA)

        TabsListManager.shared.attach(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        let tagsView = linksRouter.linkTagsController.view
        tagsView.translatesAutoresizingMaskIntoConstraints = false
        let searchView = linksRouter.searchBarController.view
        searchView.translatesAutoresizingMaskIntoConstraints = false
        
        if isPad {
            setupTabletConstraints(searchView, tagsView)
        } else {
            setupPhoneConstraints(searchView, tagsView)
        }
        
        linksRouter.hiddenWebLoadConstraint = webLoadProgressView.heightAnchor.constraint(equalToConstant: 0)
        linksRouter.showedWebLoadConstraint = webLoadProgressView.heightAnchor.constraint(equalToConstant: 6)
        linksRouter.hiddenWebLoadConstraint?.isActive = true
        webLoadProgressView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webLoadProgressView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        linksRouter.hiddenTagsConstraint?.isActive = true
        tagsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tagsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tagsView.heightAnchor.constraint(equalToConstant: .linkTagsHeight).isActive = true

        if !isPad {
            let filesView: UIView = linksRouter.filesGreedController.view
            filesView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            filesView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            // temporarily use 0 height because actual height of free space is unknown at the moment
            let greedHeight: CGFloat = 0
            linksRouter.hiddenFilesGreedConstraint = filesView.bottomAnchor.constraint(equalTo: tagsView.topAnchor,
                                                                                       constant: greedHeight)
            linksRouter.showedFilesGreedConstraint = filesView.bottomAnchor.constraint(equalTo: tagsView.topAnchor)
            linksRouter.filesGreedHeightConstraint = filesView.heightAnchor.constraint(equalToConstant: greedHeight)
            linksRouter.hiddenFilesGreedConstraint?.isActive = true
            linksRouter.filesGreedHeightConstraint?.isActive = true
        }

        setupObservers()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        // only here we can get correct value for
        // safe area inset
        if isPad {
            linksRouter.underLinksViewHeightConstraint?.constant = view.safeAreaInsets.bottom
            underLinkTagsView.setNeedsLayout()
            underLinkTagsView.layoutIfNeeded()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !isPad {
            let freeHeight: CGFloat
            let allHeight = containerView.bounds.height
            freeHeight = allHeight - .linkTagsHeight
            
            linksRouter.filesGreedHeightConstraint?.constant = freeHeight
            linksRouter.hiddenFilesGreedConstraint?.constant = freeHeight
            let filesView: UIView = linksRouter.filesGreedController.view
            filesView.setNeedsLayout()
            filesView.layoutIfNeeded()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return ThemeProvider.shared.theme.statusBarStyle
        }
    }

    deinit {
        // was in `viewWillDisappear` before
        NotificationCenter.default.removeObserver(self)
        TabsListManager.shared.detach(self)
        disposables.forEach { $0?.dispose() }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension MainBrowserViewController: TabRendererInterface {
    func open(tabContent: Tab.ContentType) {
        linksRouter.closeTags()

        switch previousTabContent {
        case .site:
            // need to stop any video/audio on corresponding web view
            // before removing it from parent view controller.
            // on iphones the video is always played in full-screen (probably need to invent workaround)
            // https://webkit.org/blog/6784/new-video-policies-for-ios/
            // "and, on iPhone, the <video> will enter fullscreen when starting playback."
            // on ipads it is played in normal mode, so, this is why need to stop/pause it
            if let currentWebViewVC = currentWebViewController {
                // also need to invalidate and cancel all observations
                // in viewDidDisappear, and not in dealloc,
                // because currently web view controller reference
                // stored in reuse manager which probably
                // not needed anymore even with unsolved memory issue when it's
                // a lot of tabs are opened.
                // It is because it's very tricky to save navigation history
                // for reused web view and for some other reasons.
                currentWebViewVC.viewController.removeFromChild()
            }
        case .topSites:
            topSitesController.viewController.removeFromChild()
        default:
            blankWebPageController.removeFromChild()
        }

        switch tabContent {
        case .site(let site):
            openSiteTabContent(with: site)
        case .topSites:
            openTopSitesTabContent()
        default:
            openBlankTabContent()
        }

        previousTabContent = tabContent
    }
    
    private func openSiteTabContent(with site: Site) {
        guard let jsPluginsSource = jsPluginsBuilder else {
            assertionFailure("Plugins source is expected to be initialized even if it is empty")
            return
        }
        // need to display progress view before load start
        linksRouter.showProgress(true)
        let vc = try? WebViewsReuseManager.shared.controllerFor(site, jsPluginsSource, self)
        guard let webViewController = vc else {
            assertionFailure("Failed create new web view for tab")
            open(tabContent: .blank)
            return
        }

        siteNavigator = webViewController
        currentWebViewController = webViewController

        add(asChildViewController: webViewController, to: containerView)
        let webVContainer: UIView = webViewController.view
        webVContainer.translatesAutoresizingMaskIntoConstraints = false
        // originally left and right were used instead of leading and trailing
        webVContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        webVContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        webVContainer.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        webVContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
    
    private func openTopSitesTabContent() {
        siteNavigator = nil
        linksRouter.searchBarController.changeState(to: .blankSearch, animated: true)
        topSitesController.reload(with: DefaultTabProvider.shared.topSites)

        add(asChildViewController: topSitesController.viewController, to: containerView)
        let topSitesView: UIView = topSitesController.view
        topSitesView.translatesAutoresizingMaskIntoConstraints = false
        topSitesView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        topSitesView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        topSitesView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        topSitesView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
    
    private func openBlankTabContent() {
        siteNavigator = nil
        linksRouter.searchBarController.changeState(to: .blankSearch, animated: true)

        add(asChildViewController: blankWebPageController, to: containerView)
        let blankView: UIView = blankWebPageController.view
        blankView.translatesAutoresizingMaskIntoConstraints = false
        blankView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        blankView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        blankView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        blankView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
}

private extension MainBrowserViewController {
    func navigationComponent() -> FullSiteNavigationComponent? {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return toolbarViewController
        } else if let tabletVc = linksRouter.searchBarController as? FullSiteNavigationComponent {
            // complex type casting
            return tabletVc
        }
        return nil
    }

    func keyboardWillChangeFrameClosure() -> (Notification) -> Void {
        func handling(_ notification: Notification) {
            guard let info = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] else { return }
            guard let value = info as? NSValue else { return }
            let rect = value.cgRectValue

            // need to reduce search suggestions list height
            mKeyboardHeight = rect.size.height
        }

        return handling
    }

    func keyboardWillHideClosure() -> (Notification) -> Void {
        func handling(_ notification: Notification) {
            mKeyboardHeight = nil
        }

        return handling
    }

    func replaceTab(with url: URL, with suggestion: String? = nil) {
        let blockPopups = DefaultTabProvider.shared.blockPopups
        let isJSEnabled = FeatureManager.boolValue(of: .javaScriptEnabled)
        let settings = Site.Settings(isPrivate: false,
                                     blockPopups: blockPopups,
                                     isJSEnabled: isJSEnabled,
                                     canLoadPlugins: true)
        guard let site = Site.create(url: url,
                                     searchSuggestion: suggestion,
                                     settings: settings) else {
            assertionFailure("\(#function) failed to replace current tab - failed create site")
            return
        }
        let siteContent: Tab.ContentType = .site(site)
        // tab content replacing will happen in `didCommit`
        open(tabContent: siteContent)
    }
}

extension MainBrowserViewController: AnyViewController {}

extension MainBrowserViewController: MainDelegate {
    var popoverSourceView: UIView {
        return containerView
    }

    var keyboardHeight: CGFloat? {
        get {
            return mKeyboardHeight
        }
        set (newValue) {
            mKeyboardHeight = newValue
        }
    }

    /// Dynamicly determined height because it can be different before layout finish it's work
    var toolbarHeight: CGFloat {
        return toolbarViewController.view.bounds.size.height + underToolbarView.bounds.size.height
    }

    var toolbarTopAnchor: NSLayoutYAxisAnchor {
        return toolbarViewController.view.topAnchor
    }

    func openSearchSuggestion(url: URL, suggestion: String) {
        replaceTab(with: url, with: suggestion)
    }

    func openDomain(with url: URL) {
        replaceTab(with: url)
    }
}

extension MainBrowserViewController: TabsObserver {
    func didSelect(index: Int, content: Tab.ContentType, identifier: UUID) {
        open(tabContent: content)
    }

    func tabDidReplace(_ tab: Tab, at index: Int) {
        switch previousTabContent {
        case .site:
            break
        default:
            open(tabContent: tab.contentType)
        }

        // need update navigation if the same tab was updated
        let withSite: Bool
        if case .site = tab.contentType {
            withSite = true
        } else {
            withSite = false
        }

        linksRouter.closeTags()
        reloadNavigationElements(withSite)
    }
}

extension MainBrowserViewController: SiteNavigationComponent {
    func reloadNavigationElements(_ withSite: Bool, downloadsAvailable: Bool = false) {
        navigationComponent()?.reloadNavigationElements(withSite, downloadsAvailable: downloadsAvailable)
    }

    var siteNavigator: SiteNavigationDelegate? {
        get {
            return nil
        }
        set(newValue) {
            let holder = navigationComponent()
            holder?.siteNavigator = newValue
            self.linksRouter.siteNavigationDelegate = newValue
        }
    }
}

extension MainBrowserViewController: InstagramContentDelegate {
    func didReceiveVideoNodes(_ nodes: [InstagramVideoNode]) {
        linksRouter.openTagsFor(instagram: nodes)
        reloadNavigationElements(true, downloadsAvailable: true)
    }
}

extension MainBrowserViewController: BasePluginContentDelegate {
    func didReceiveVideoTags(_ tags: [HTMLVideoTag]) {
        linksRouter.openTagsFor(html: tags)
        reloadNavigationElements(true, downloadsAvailable: true)
    }
}

extension MainBrowserViewController: SiteExternalNavigationDelegate {
    func didUpdateBackNavigation(to canGoBack: Bool) {
        navigationComponent()?.changeBackButton(to: canGoBack)
    }
    
    func didUpdateForwardNavigation(to canGoForward: Bool) {
        navigationComponent()?.changeForwardButton(to: canGoForward)
    }
    
    func didStartProvisionalNavigation() {
        linksRouter.closeTags()
    }

    func didOpenSiteWith(appName: String) {
        // notify user to remove speicifc application from iOS
        // to be able to use Cotton browser features
    }
    
    func displayProgress(_ progress: Double) {
        webLoadProgressView.setProgress(Float(progress), animated: false)
    }
    
    func showProgress(_ show: Bool) {
        linksRouter.showProgress(show)
        webLoadProgressView.setProgress(0, animated: false)
    }
    
    func updateTabPreview(_ screenshot: UIImage) {
        try? TabsListManager.shared.setSelectedPreview(screenshot)
    }
    
    func openTabMenu(from sourceView: UIView,
                     and sourceRect: CGRect,
                     for host: Host,
                     siteSettings: Site.Settings) {
        linksRouter.openTabMenu(from: sourceView,
                                and: sourceRect,
                                for: host,
                                siteSettings: siteSettings)
    }
    // swiftlint:disable:next file_length
}