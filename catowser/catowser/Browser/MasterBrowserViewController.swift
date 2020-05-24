//
//  MasterBrowserViewController.swift
//  catowser
//
//  Created by Andrey Ermoshin on 27/09/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import UIKit
import ReactiveSwift
import CoreBrowser
import JSPlugins

/// An interface for component which suppose to render tabs
///
/// Class protocol is used because object gonna be stored by `weak` ref
/// `AnyObject` is new name for it, but will use old one to find when XCode
/// will start mark it as deprecated.
/// https://forums.swift.org/t/class-only-protocols-class-vs-anyobject/11507/4
protocol TabRendererInterface: AnyViewController {
    func open(tabContent: Tab.ContentType)
}

final class MasterBrowserViewController: BaseViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    /// Router and layout handler for supplementary views.
    private var linksRouter: MasterRouter!

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
        let toolbar = WebBrowserToolbarController(router: router, delegate: linksRouter)
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
    private var currentWebViewController: WebViewController?

    private var disposables = [Disposable?]()

    private let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad ? true : false

    private var jsPluginsBuilder: PluginsBuilder?

    /// Not initialized, will be initialized after `TabsListManager`
    /// during tab opening. Used only during tab opening for optimization
    private var previousTabContent: Tab.ContentType?
    
    override func loadView() {
        // Your custom implementation of this method should not call super.
        view = UIView()
        
        // In that method, create your view hierarchy programmatically and assign
        // the root view of that hierarchy to the view controller’s view property.
        
        if isPad {
            add(asChildViewController: tabsViewController, to: view)
        }

        linksRouter = MasterRouter(viewController: self)

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        
        if isPad {
            let tabsTop = tabsViewController.view.topAnchor
            // https://github.com/SnapKit/SnapKit/issues/448
            // https://developer.apple.com/documentation/uikit/uiviewcontroller/1621367-toplayoutguide
            // https://developer.apple.com/documentation/uikit/uiview/2891102-safearealayoutguide
            if #available(iOS 11, *) {
                tabsTop.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            } else {
                tabsTop.constraint(equalTo: view.topAnchor).isActive = true
            }
            tabsViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            tabsViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            tabsViewController.view.heightAnchor.constraint(equalToConstant: .tabHeight).isActive = true
            
            let searchView = linksRouter.searchBarController.view
            searchView.topAnchor.constraint(equalTo: tabsViewController.view.bottomAnchor).isActive = true
            searchView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            searchView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            searchView.heightAnchor.constraint(equalToConstant: .searchViewHeight).isActive = true
            
            let sbViewBottomAnchor = linksRouter.searchBarController.view.bottomAnchor
            webLoadProgressView.topAnchor.constraint(equalTo: sbViewBottomAnchor).isActive = true
            
            // Need to have not simple view controller view but container view
            // to have ability to insert to it and show view controller with
            // bookmarks in case if search bar has no any address entered or
            // webpage controller with web view if some address entered in search bar
            containerView.topAnchor.constraint(equalTo: webLoadProgressView.bottomAnchor).isActive = true
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

            underLinkTagsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
            underLinkTagsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
            let dummyViewHeight: CGFloat = .safeAreaBottomMargin
            let linksHConstraint = underLinkTagsView.heightAnchor.constraint(equalToConstant: dummyViewHeight)
            linksRouter.underLinksViewHeightConstraint = linksHConstraint
            linksRouter.underLinksViewHeightConstraint?.isActive = true

            let bottomMargin: CGFloat = dummyViewHeight + .linkTagsHeight
            linksRouter.hiddenTagsConstraint = underLinkTagsView.bottomAnchor.constraint(equalTo: view.bottomAnchor,
                                                                                         constant: bottomMargin)
            linksRouter.showedTagsConstraint = underLinkTagsView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            let tagsBottom = linksRouter.linkTagsController.view.bottomAnchor
            tagsBottom.constraint(equalTo: underLinkTagsView.topAnchor).isActive = true
        } else {
            let searchView = linksRouter.searchBarController.view
            if #available(iOS 11, *) {
                searchView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            } else {
                searchView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            }
            searchView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            searchView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            searchView.heightAnchor.constraint(equalToConstant: .searchViewHeight).isActive = true
            
            webLoadProgressView.topAnchor.constraint(equalTo: linksRouter.searchBarController.view.bottomAnchor,
                                                     constant: 0).isActive = true
            
            containerView.topAnchor.constraint(equalTo: webLoadProgressView.bottomAnchor).isActive = true
            containerView.bottomAnchor.constraint(equalTo: toolbarViewController.view.topAnchor).isActive = true
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            
            let toolbarView: UIView = toolbarViewController.view
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
            
            let tagsView = linksRouter.linkTagsController.view
            linksRouter.hiddenTagsConstraint = tagsView.bottomAnchor.constraint(equalTo: toolbarView.topAnchor, constant: .linkTagsHeight)
            linksRouter.showedTagsConstraint = tagsView.bottomAnchor.constraint(equalTo: toolbarView.topAnchor)
        }
        
        linksRouter.hiddenWebLoadConstraint = webLoadProgressView.heightAnchor.constraint(equalToConstant: 0)
        linksRouter.showedWebLoadConstraint = webLoadProgressView.heightAnchor.constraint(equalToConstant: 6)
        linksRouter.hiddenWebLoadConstraint?.isActive = true
        webLoadProgressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        webLoadProgressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        
        linksRouter.hiddenTagsConstraint?.isActive = true
        linksRouter.linkTagsController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        linksRouter.linkTagsController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    linksRouter.linkTagsController.view.heightAnchor.constraint(equalToConstant: .linkTagsHeight).isActive = true

        if !isPad {
            linksRouter.filesGreedController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            linksRouter.filesGreedController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            // temporarily use 0 height because actual height of free space is unknown at the moment
            let greedHeight: CGFloat = 0
            linksRouter.hiddenFilesGreedConstraint = linksRouter.filesGreedController.view.bottomAnchor.constraint(equalTo: linksRouter.linkTagsController.view.topAnchor, constant: greedHeight)
            linksRouter.showedFilesGreedConstraint = linksRouter.filesGreedController.view.bottomAnchor.constraint(equalTo: linksRouter.linkTagsController.view.topAnchor)
            linksRouter.filesGreedHeightConstraint = linksRouter.filesGreedController.view.heightAnchor.constraint(equalToConstant: greedHeight)
            linksRouter.hiddenFilesGreedConstraint?.isActive = true
            linksRouter.filesGreedHeightConstraint?.isActive = true
        }

        jsPluginsBuilder = JSPluginsBuilder(baseDelegate: self, instagramDelegate: self, t4Delegate: self)

        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                               object: nil,
                                               queue: nil,
                                               using: keyboardWillHideClosure())

        let disposeA = NotificationCenter.default.reactive
            .notifications(forName: UIResponder.keyboardDidChangeFrameNotification)
            .observe(on: UIScheduler())
            .observeValues {[weak self] notification in
                self?.keyboardWillChangeFrameClosure()(notification)
        }

        disposables.append(disposeA)

        TabsListManager.shared.attach(self)
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
            linksRouter.filesGreedController.view.setNeedsLayout()
            linksRouter.filesGreedController.view.layoutIfNeeded()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return ThemeProvider.shared.theme.statusBarStyle
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }

    deinit {
        TabsListManager.shared.detach(self)
        disposables.forEach { $0?.dispose() }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension MasterBrowserViewController: TabRendererInterface {
    func open(tabContent: Tab.ContentType) {
        linksRouter.closeTags()

        if let currentTabContentType = previousTabContent {
            switch currentTabContentType {
            case .site:
                // need to stop any video/audio on corresponding web view
                // before removing it from parent view controller.
                // on iphones the video is always played in full-screen (probably need to invent workaround)
                // https://webkit.org/blog/6784/new-video-policies-for-ios/
                // "and, on iPhone, the <video> will enter fullscreen when starting playback."
                // on ipads it is played in normal mode, so, this is why need to stop/pause it
                if let currentWebViewVC = currentWebViewController {
                    // currentWebViewVC.
                    currentWebViewVC.removeFromChild()
                }
            case .topSites:
                topSitesController.viewController.removeFromChild()
            default:
                blankWebPageController.removeFromChild()
            }
        }

        switch tabContent {
        case .site(let site):
            guard let pluginsBuilder = jsPluginsBuilder else {
                assertionFailure("Failed show site - no plugins")
                open(tabContent: .blank)
                return
            }
            // need to display progress view before load start
            linksRouter.showProgress(true)
            let viewController = try? WebViewsReuseManager.shared.controllerFor(site,
                                                                                pluginsBuilder: pluginsBuilder,
                                                                                delegate: self)
            guard let webViewController = viewController else {
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
        case .topSites:
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
        default:
            siteNavigator = nil
            linksRouter.searchBarController.changeState(to: .blankSearch, animated: true)

            add(asChildViewController: blankWebPageController, to: containerView)
            let blankView: UIView = blankWebPageController.view
            blankView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
            blankView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
            blankView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            blankView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        }

        previousTabContent = tabContent
    }
}

private extension MasterBrowserViewController {
    func navigationComponent() -> SiteNavigationComponent? {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return toolbarViewController
        } else if let tabletVc = linksRouter.searchBarController as? SiteNavigationComponent {
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
        guard let site = Site(url: url, searchSuggestion: suggestion) else {
            assertionFailure("\(#function) failed to replace current tab - failed create site")
            return
        }
        let siteContent: Tab.ContentType = .site(site)
        // tab content replacing will happen in `didCommit`
        open(tabContent: siteContent)
    }
}

extension MasterBrowserViewController: AnyViewController {}

extension MasterBrowserViewController: MasterDelegate {
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

extension MasterBrowserViewController: TabsObserver {
    func didSelect(index: Int, content: Tab.ContentType) {
        open(tabContent: content)
    }

    func tabDidReplace(_ tab: Tab, at index: Int) {
        if let currentContentType = previousTabContent {
            switch currentContentType {
            case .site:
                break
            default:
                open(tabContent: tab.contentType)
            }
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

extension MasterBrowserViewController: SiteNavigationComponent {
    func changeBackButton(to canGoBack: Bool) {
        // TODO: change conformans to `SiteNavigationComponent` to not write protocol functions two times
    }
    
    func changeForwardButton(to canGoForward: Bool) {
        // TODO: change conformans to `SiteNavigationComponent` to not write protocol functions two times
    }
    
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
        }
    }
}

extension MasterBrowserViewController: InstagramContentDelegate {
    func didReceiveVideoNodes(_ nodes: [InstagramVideoNode]) {
        linksRouter.openTagsFor(instagram: nodes)
        reloadNavigationElements(true, downloadsAvailable: true)
    }
}

extension MasterBrowserViewController: T4ContentDelegate {
    func didReceiveVideo(_ video: T4Video) {
        linksRouter.openTagsFor(t4: video)
        reloadNavigationElements(true, downloadsAvailable: true)
    }
}

extension MasterBrowserViewController: BasePluginContentDelegate {
    func didReceiveVideoTags(_ tags: [HTMLVideoTag]) {
        linksRouter.openTagsFor(html: tags)
        reloadNavigationElements(true, downloadsAvailable: true)
    }
}

extension MasterBrowserViewController: SiteExternalNavigationDelegate {
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
    
    func openTabMenu(from sourceView: UIView, and sourceRect: CGRect) {
        linksRouter.openTabMenu(from: sourceView, and: sourceRect)
    }
}
