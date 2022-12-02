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
    /// Dummy view coordinator
    private var bottomViewCoordinator: BottomViewCoordinator?
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
    /// Need to update this navigation delegate each time it changes in router holder
    private weak var siteNavigationDelegate: SiteNavigationDelegate?
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
    case openTab(Tab.ContentType)
}

extension AppCoordinator: Navigating {
    typealias R = MainScreenRoute
    
    func showNext(_ route: R) {
        switch route {
        case .menu(let model, let sourceView, let sourceRect):
            startMenu(model, sourceView, sourceRect)
        case .openTab(let content):
            open(tabContent: content)
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
    case tabs
    case searchBar
    case loadingProgress
    case webContentContainer
    case filesGrid
    case linkTags
    case toolbar
    case dummyView
}

extension AppCoordinator: Layouting {
    typealias SP = MainScreenSubview
    
    func insertNext(_ subview: SP) {
        switch subview {
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
        case .dummyView:
            insertDummyView()
        }
    }
    
    func layout(_ step: OwnLayoutStep) {
        
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    func layoutNext(_ step: LayoutStep<SP>) {
        switch step {
        case .viewDidLoad(let subview):
            switch subview {
            case .tabs:
                tabsViewDidLoad()
            case .searchBar:
                searchBarViewDidLoad()
            case .loadingProgress:
                loadingProgressViewDidLoad()
            case .webContentContainer:
                webContentContainerViewDidLoad()
            case .filesGrid:
                filesGridViewDidLoad()
            case .linkTags:
                linkTagsViewDidLoad()
            case .toolbar:
                toolbarViewDidLoad()
            case .dummyView:
                dummyViewDidLoad()
            }
        case .viewDidLayoutSubviews(let subview, _):
            switch subview {
            case .filesGrid:
                filesGridViewDidLayoutSubviews()
            default:
                break
            }
        case .viewSafeAreaInsetsDidChange(let subview):
            switch subview {
            case .dummyView:
                dummyViewSafeAreaInsetsDidChange()
            default:
                break
            }
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
        linkTagsCoordinator?.showNext(.openInstagramTags(nodes))
        reloadNavigationElements(true, downloadsAvailable: true)
    }
}

extension AppCoordinator: BasePluginContentDelegate {
    func didReceiveVideoTags(_ tags: [HTMLVideoTag]) {
        linkTagsCoordinator?.showNext(.openHtmlTags(tags))
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
        linkTagsCoordinator?.insertNext(.filesGrid)
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
    
    func insertDummyView() {
        // swiftlint:disable:next force_unwrapping
        let presenter = startedVC!
        let coordinator: BottomViewCoordinator = .init(vcFactory, presenter)
        coordinator.parent = self
        coordinator.start()
        bottomViewCoordinator = coordinator
    }
    
    // MARK: - layout methods to layout subviews
    
    func tabsViewDidLoad() {
        guard isPad else {
            return
        }
        tabletTabsCoordinator?.layout(.viewDidLoad())
    }
    
    func searchBarViewDidLoad() {
        // use specific bottom anchor when it is Tablet layout
        // and the most top view is not a superview but tabs view
        let topAnchor = tabletTabsCoordinator?.startedVC?.controllerView.bottomAnchor
        searchBarCoordinator?.layout(.viewDidLoad(topAnchor, nil))
    }
    
    func loadingProgressViewDidLoad() {
        let topAnchor = searchBarCoordinator?.startedVC?.controllerView.bottomAnchor
        loadingProgressCoordinator?.layout(.viewDidLoad(topAnchor))
    }
    
    func filesGridViewDidLoad() {
        linkTagsCoordinator?.layoutNext(.viewDidLoad(.filesGrid))
    }
    
    func webContentContainerViewDidLoad() {
        let bottomAnchor = toolbarCoordinator?.startedVC?.controllerView.topAnchor
        webContentContainerCoordinator?.layout(.viewDidLoad(nil, bottomAnchor))
    }
    
    func toolbarViewDidLoad() {
        let topAnchor = webContentContainerCoordinator?.containerView.bottomAnchor
        toolbarCoordinator?.layout(.viewDidLoad(topAnchor, nil))
    }
    
    func dummyViewDidLoad() {
        let topAnchor = toolbarCoordinator?.startedVC?.controllerView.bottomAnchor
        bottomViewCoordinator?.layout(.viewDidLoad(topAnchor, nil))
    }
    
    func dummyViewSafeAreaInsetsDidChange() {
        bottomViewCoordinator?.layout(.viewSafeAreaInsetsDidChange)
    }
    
    // MARK: - lifecycle navigation methods
    
    func startMenu(_ model: SiteMenuModel, _ sourceView: UIView, _ sourceRect: CGRect) {
        // swiftlint:disable:next force_unwrapping
        let presenter = startedVC!
        let coordinator: GlobalMenuCoordinator = .init(vcFactory, presenter, model, sourceView, sourceRect)
        coordinator.parent = self
        coordinator.start()
        startedCoordinator = coordinator
    }

    
    func insertTopSites() {
        guard let containerView = webContentContainerCoordinator?.containerView else {
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
        guard let containerView = webContentContainerCoordinator?.containerView else {
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
        guard let containerView = webContentContainerCoordinator?.containerView,
                let plugins = jsPluginsBuilder else {
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
        linkTagsCoordinator?.showNext(.closeTags)

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
            loadingProgressCoordinator?.showNext(.showProgress(true))
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
    
    func linkTagsViewDidLoad() {
        let topAnchor: NSLayoutYAxisAnchor
        let bottomAnchor: NSLayoutYAxisAnchor?
        if isPad {
            // swiftlint:disable:next force_unwrapping
            topAnchor = (bottomViewCoordinator?.tabletTopAnchor)!
            // swiftlint:disable:next force_unwrapping
            bottomAnchor = (bottomViewCoordinator?.tabletBottomAnchor)!
        } else {
            // swiftlint:disable:next force_unwrapping
            topAnchor = (toolbarCoordinator?.startedVC?.controllerView.topAnchor)!
            bottomAnchor = nil
        }
        linkTagsCoordinator?.layout(.viewDidLoad(topAnchor, bottomAnchor))
    }
    
    func filesGridViewDidLayoutSubviews() {
        guard let containerHeight = webContentContainerCoordinator?.containerView.bounds.height else {
            return
        }
        linkTagsCoordinator?.layoutNext(.viewDidLayoutSubviews(.filesGrid, containerHeight))
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

        linkTagsCoordinator?.showNext(.closeTags)
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
        linkTagsCoordinator?.showNext(.closeTags)
    }
    
    func didLoadingProgressChange(_ progress: Float) {
        loadingProgressCoordinator?.showNext(.setProgress(progress, false))
    }
    
    func didProgress(show: Bool) {
        loadingProgressCoordinator?.showNext(.showProgress(show))
        loadingProgressCoordinator?.showNext(.setProgress(0, false))
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
        return toolbarHeight + (bottomViewCoordinator?.underToolbarViewBounds?.height ?? 24)
    }
    
    func openTab(_ content: Tab.ContentType) {
        showNext(.openTab(content))
    }
}
