//
//  AppCoordinator.swift
//  catowser
//
//  Created by Andrey Ermoshin on 13.11.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser
import CoreHttpKit
import FeaturesFlagsKit
import JSPlugins

final class AppCoordinator: Coordinator, CoordinatorOwner {
    var startedCoordinator: Coordinator?
    weak var parent: CoordinatorOwner?
    let vcFactory: ViewControllerFactory
    var startedVC: AnyViewController?
    weak var presenterVC: AnyViewController?
    
    /// Specific toolbar coordinator which should stay forever
    private var toolbarCoordinator: MainToolbarCoordinator?
    /// Progress view coordinator, TODO: needs to be replaced with base protocol
    private var loadingProgressCoordinator: LoadingProgressCoordinator?
    ///
    private var webContentContainerCoordinator: WebContentContainerCoordinator?
    /// Search bar coordinator
    private var searchBarCoordinator: SearchBarCoordinator?
    /// Specific link for tags coordinator
    private var linkTagsCoordinator: LinkTagsCoordinator?
    /// Coordinator for inserted child view controller
    private var topSitesCoordinator: (any Navigating)?
    /// blank content vc
    private var blankContentCoordinator: (any Navigating)?
    /// web view coordinator
    private var webContentCoordinator: (any Navigating)?
    /// This coordinator is optional because it is only needed on Tablet
    private var tabletTabsCoordinator: TabletTabsCoordinator?
    /// App window rectangle
    private let windowRectangle: CGRect = {
        CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }()
    /// main app window
    private let window: UIWindow
    /// Not initialized, will be initialized after `TabsListManager`
    /// during tab opening. Used only during tab opening for optimization
    private lazy var previousTabContent: Tab.ContentType = FeatureManager.tabDefaultContentValue().contentType
    /// Temporary property, MUST be removed during refactoring
    var layoutCoordinator: AppLayoutCoordinator?
    /// Need to update this navigation delegate each time it changes in router holder
    private weak var siteNavigationDelegate: SiteNavigationDelegate?
    /// Convinience property to get a content container from root view controller
    private var contentContainerView: UIView? {
        (startedVC as? BrowserContentViewHolder)?.containerView
    }
    /// Convinience property for specific view bounds
    private var underToolbarViewBounds: CGRect? {
        (startedVC as? BrowserContentViewHolder)?.underToolbarViewBounds
    }
    /// Not a constant because can't be initialized in init
    private var jsPluginsBuilder: (any JSPluginsSource)?
    /// Web site navigation delegate
    private var navigationComponent: FullSiteNavigationComponent? {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return vcFactory.createdToolbaViewController as? FullSiteNavigationComponent
        } else {
            return vcFactory.createdDeviceSpecificSearchBarVC as? FullSiteNavigationComponent
        }
    }
    
    init(_ vcFactory: ViewControllerFactory) {
        self.vcFactory = vcFactory
        window = UIWindow(frame: windowRectangle)
    }
    
    func start() {
        let vc = vcFactory.rootViewController(self)
        startedVC = vc
        layoutCoordinator = AppLayoutCoordinator(vc, self)
        window.rootViewController = startedVC?.viewController
        window.makeKeyAndVisible()
        
        TabsListManager.shared.attach(self)
        jsPluginsBuilder = JSPluginsBuilder()
            .setBase(self)
            .setInstagram(self)
    }
}

enum MainScreenRoute: Route {
    case menu(SiteMenuModel, UIView, CGRect)
}

extension AppCoordinator: Navigating {
    typealias R = MainScreenRoute
    
    func showNext(_ route: R) {
        switch route {
        case .menu(let model, let sourceView, let sourceRect):
            startMenu(model, sourceView, sourceRect)
        }
    }
    
    func stop() {
        // Probably it is not necessary because this coordinator
        // is the root one
        TabsListManager.shared.detach(self)
        parent?.didFinish()
    }
}

enum MainScreenSubview: SubviewPart {
    // MARK: - views
    case tabs
    case searchBar
    case loadingProgress
    case webContentContainer
    case filesGrid
    case linkTags
    case toolbar
    // MARK: - layout
    case tabsViewDidLoad
    case searchBarViewDidLoad
    case loadingProgressViewDidLoad
    case filesGridViewDidLoad
    case webContentContainerViewDidLoad
    case toolbarViewDidLoad
    
    case linkTagsViewDidLoad(NSLayoutYAxisAnchor, NSLayoutYAxisAnchor?)
    
    case filesGridViewDidLayoutSubviews(CGFloat)
    case openTab(Tab.ContentType)
}

extension AppCoordinator: SubviewNavigation {
    typealias SP = MainScreenSubview
    
    // swiftlint:disable:next cyclomatic_complexity
    func insertNext(_ subview: SP) {
        switch subview {
            // MARK: - views insertion
        case .tabs:
            insertTabs()
        case .searchBar:
            insertSearchBar()
        case .loadingProgress:
            insertLoadingProgress()
        case .webContentContainer:
            insertWebContentContainer()
        case .filesGrid:
            insertFilesGrid()
        case .linkTags:
            insertLinkTags()
        case .toolbar:
            insertToolbar()
            // MARK: - views layout
        case .tabsViewDidLoad:
            tabsViewDidLoad()
        case .searchBarViewDidLoad:
            searchBarViewDidLoad()
        case .loadingProgressViewDidLoad:
            loadingProgressViewDidLoad()
        case .filesGridViewDidLoad:
            filesGridViewDidLoad()
        case .webContentContainerViewDidLoad:
            webContentContainerViewDidLoad()
        case .toolbarViewDidLoad:
            toolbarViewDidLoad()
            
            // MARK: - view did layout subviews
        
            // MARK: - lifecycle navigation actions
        case .openTab(let content):
            open(tabContent: content)
        case .linkTagsViewDidLoad(let topAnchor, let bottomAnchor):
            linkTagsViewDidLoad(topAnchor, bottomAnchor)
        case .filesGridViewDidLayoutSubviews(let containerHeight):
            filesGridViewDidLayoutSubviews(containerHeight)
        }
    }
}

extension AppCoordinator: SiteNavigationComponent {
    func reloadNavigationElements(_ withSite: Bool, downloadsAvailable: Bool = false) {
        navigationComponent?.reloadNavigationElements(withSite, downloadsAvailable: downloadsAvailable)
    }

    var siteNavigator: SiteNavigationDelegate? {
        get {
            return nil
        }
        set(newValue) {
            navigationComponent?.siteNavigator = newValue
            siteNavigationDelegate = newValue
        }
    }
}

extension AppCoordinator: InstagramContentDelegate {
    func didReceiveVideoNodes(_ nodes: [InstagramVideoNode]) {
        linkTagsCoordinator?.insertNext(.openInstagramTags(nodes))
        reloadNavigationElements(true, downloadsAvailable: true)
    }
}

extension AppCoordinator: BasePluginContentDelegate {
    func didReceiveVideoTags(_ tags: [HTMLVideoTag]) {
        linkTagsCoordinator?.insertNext(.openHtmlTags(tags))
        reloadNavigationElements(true, downloadsAvailable: true)
    }
}

private extension AppCoordinator {
    
    // MARK: - insert methods to start subview coordinators
    
    func insertTabs() {
        guard isPad else {
            return
        }
        // swiftlint:disable:next force_unwrapping
        let presenter = startedVC!
        let coordinator: TabletTabsCoordinator = .init(vcFactory, presenter)
        coordinator.parent = self
        coordinator.start()
        tabletTabsCoordinator = coordinator
    }
    
    func insertSearchBar() {
        // swiftlint:disable:next force_unwrapping
        let presenter = startedVC!
        let coordinator: SearchBarCoordinator = .init(vcFactory,
                                                      presenter,
                                                      linkTagsCoordinator,
                                                      self,
                                                      self)
        coordinator.parent = self
        coordinator.start()
        searchBarCoordinator = coordinator
    }
    
    func insertLoadingProgress() {
        // swiftlint:disable:next force_unwrapping
        let presenter = startedVC!
        let coordinator: LoadingProgressCoordinator = .init(vcFactory, presenter)
        coordinator.parent = self
        coordinator.start()
        loadingProgressCoordinator = coordinator
    }
    
    func insertWebContentContainer() {
        // swiftlint:disable:next force_unwrapping
        let presenter = startedVC!
        let coordinator: WebContentContainerCoordinator = .init(vcFactory, presenter)
        coordinator.parent = self
        coordinator.start()
        webContentContainerCoordinator = coordinator
    }
    
    func insertFilesGrid() {
        linkTagsCoordinator?.insertNext(.insertFilesGrid)
    }
    
    func insertLinkTags() {
        // swiftlint:disable:next force_unwrapping
        let presenter = startedVC!
        let coordinator: LinkTagsCoordinator = .init(vcFactory, presenter)
        coordinator.parent = self
        coordinator.start()
        linkTagsCoordinator = coordinator
    }
    
    func insertToolbar() {
        // swiftlint:disable:next force_unwrapping
        let presenter = startedVC!
        let coordinator: MainToolbarCoordinator = .init(vcFactory,
                                                        presenter,
                                                        linkTagsCoordinator,
                                                        self)
        coordinator.parent = self
        coordinator.start()
        toolbarCoordinator = coordinator
    }
    
    // MARK: - layout methods to layout subviews
    
    func tabsViewDidLoad() {
        guard isPad else {
            return
        }
        tabletTabsCoordinator?.insertNext(.viewDidLoad)
    }
    
    func searchBarViewDidLoad() {
        // use specific bottom anchor when it is Tablet layout
        // and the most top view is not a superview but tabs view
        searchBarCoordinator?.insertNext(.viewDidLoad(tabletTabsCoordinator?.startedVC?.controllerView.bottomAnchor))
    }
    
    func loadingProgressViewDidLoad() {
        guard let bottomAnchor = searchBarCoordinator?.startedVC?.controllerView.bottomAnchor else {
            return
        }
        loadingProgressCoordinator?.insertNext(.viewDidLoad(bottomAnchor))
    }
    
    func filesGridViewDidLoad() {
        linkTagsCoordinator?.insertNext(.filesGridViewDidLoad)
    }
    
    func webContentContainerViewDidLoad() {
        let anchor = toolbarCoordinator?.startedVC?.controllerView.topAnchor
        webContentContainerCoordinator?.insertNext(.viewDidLoad(anchor))
    }
    
    func toolbarViewDidLoad() {
        toolbarCoordinator?.insertNext(.viewDidLoad)
    }
    
    // MARK: - lifecycle navigation methods
    
    func startMenu(_ model: SiteMenuModel, _ sourceView: UIView, _ sourceRect: CGRect) {
        // swiftlint:disable:next force_unwrapping
        let presenter = startedVC!
        let coordinator: GlobalMenuCoordinator = .init(vcFactory,
                                                       presenter,
                                                       model,
                                                       sourceView,
                                                       sourceRect)
        coordinator.parent = self
        coordinator.start()
        startedCoordinator = coordinator
    }

    
    func insertTopSites() {
        guard let containerView = contentContainerView else {
            assertionFailure("Root view controller must have content view")
            return
        }
        // swiftlint:disable:next force_unwrapping
        let presenter = startedVC!
        let coordinator: TopSitesCoordinator = .init(vcFactory, presenter, containerView)
        coordinator.parent = self
        coordinator.start()
        topSitesCoordinator = coordinator
    }
    
    func insertBlankTab() {
        guard let containerView = contentContainerView else {
            assertionFailure("Root view controller must have content view")
            return
        }
        // swiftlint:disable:next force_unwrapping
        let presenter = startedVC!
        let coordinator: BlankContentCoordinator = .init(vcFactory, presenter, containerView)
        coordinator.parent = self
        coordinator.start()
        blankContentCoordinator = coordinator
    }
    
    func insertWebTab(_ site: Site) {
        guard let containerView = contentContainerView, let plugins = jsPluginsBuilder else {
            assertionFailure("Root view controller must have content view")
            return
        }
        // swiftlint:disable:next force_unwrapping
        let presenter = startedVC!
        let coordinator: WebContentCoordinator = .init(vcFactory,
                                                       presenter,
                                                       containerView,
                                                       self,
                                                       site,
                                                       plugins)
        coordinator.parent = self
        coordinator.start()
        webContentCoordinator = coordinator
    }
    
    // MARK: - Open tab content functions
    
    func open(tabContent: Tab.ContentType) {
        linkTagsCoordinator?.insertNext(.closeTags)

        switch previousTabContent {
        case .site:
            webContentCoordinator?.stop()
        case .topSites:
            topSitesCoordinator?.stop()
        default:
            blankContentCoordinator?.stop()
        }

        switch tabContent {
        case .site(let site):
            // need to display progress view before load start
            loadingProgressCoordinator?.insertNext(.showProgress(true))
            insertWebTab(site)
        case .topSites:
            siteNavigator = nil
            searchBarCoordinator?.showNext(.changeState(.blankSearch, true))
            insertTopSites()
        default:
            siteNavigator = nil
            searchBarCoordinator?.showNext(.changeState(.blankSearch, true))
            insertBlankTab()
        }

        previousTabContent = tabContent
    }
    
    func linkTagsViewDidLoad(_ topAnchor: NSLayoutYAxisAnchor, _ bottomAnchor: NSLayoutYAxisAnchor?) {
        linkTagsCoordinator?.insertNext(.viewDidLoad(topAnchor, bottomAnchor))
    }
    
    func filesGridViewDidLayoutSubviews(_ containerHeight: CGFloat) {
        linkTagsCoordinator?.insertNext(.filesGridViewDidLayoutSubviews(containerHeight))
    }
}

extension AppCoordinator: TabsObserver {
    func tabDidSelect(index: Int, content: Tab.ContentType, identifier: UUID) {
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

        linkTagsCoordinator?.insertNext(.closeTags)
        reloadNavigationElements(withSite)
    }
}

extension AppCoordinator: GlobalMenuDelegate {
    func didPressSettings(from sourceView: UIView, and sourceRect: CGRect) {
        let menuModel: SiteMenuModel = .init(.onlyGlobalMenu, siteNavigationDelegate)
        showNext(.menu(menuModel, sourceView, sourceRect))
    }
}

extension AppCoordinator: WebContentDelegate {
    func didProvisionalNavigationStart() {
        linkTagsCoordinator?.insertNext(.closeTags)
    }
    
    func didLoadingProgressChange(_ progress: Float) {
        loadingProgressCoordinator?.insertNext(.setProgress(progress, false))
    }
    
    func didProgress(show: Bool) {
        loadingProgressCoordinator?.insertNext(.showProgress(show))
        loadingProgressCoordinator?.insertNext(.setProgress(0, false))
    }
}

extension AppCoordinator: SearchBarDelegate {
    var toolbarTopAnchor: NSLayoutYAxisAnchor {
        // swiftlint:disable:next force_unwrapping
        return (toolbarCoordinator?.startedVC?.controllerView.topAnchor)!
    }
    
    /// Dynamicly determined height because it can be different before layout finish it's work
    var toolbarHeight: CGFloat {
        let toolbarHeight = toolbarCoordinator?.startedVC?.controllerView.bounds.height ?? 24
        return toolbarHeight + (underToolbarViewBounds?.height ?? 24)
    }
    
    func openTab(_ content: Tab.ContentType) {
        insertNext(.openTab(content))
    }
}
