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

final class AppCoordinator: Coordinator {
    /// Could be accessed using `WebViewsEnvironment.shared.viewControllerFactory` singleton as well
    let vcFactory: ViewControllerFactory
    /// Currently presented (next) coordinator, to be able to stop it
    var startedCoordinator: Coordinator?
    /// Root coordinator doesn't have any parent
    weak var parent: CoordinatorOwner?
    /// This specific coordinator starts root view controller
    var startedVC: AnyViewController?
    /// There is no presenter view controller in App/root coordinator
    weak var presenterVC: AnyViewController?
    var navigationStack: UINavigationController?
    
    /// Phone toolbar coordinator which should stay forever
    private var toolbarCoordinator: (any Layouting)?
    /// Progress view coordinator
    private var loadingProgressCoordinator: LoadingProgressCoordinator?
    /// Web content container coordinator
    private var webContentContainerCoordinator: (any Layouting)?
    /// Search bar coordinator
    private var searchBarCoordinator: SearchBarCoordinator?
    /// Specific link for tags coordinator
    private var linkTagsCoordinator: LinkTagsCoordinator?
    /// Dummy view coordinator
    private var bottomViewCoordinator: (any Layouting)?
    /// Coordinator for inserted child view controller
    private var topSitesCoordinator: (any Navigating)?
    /// blank content vc
    private var blankContentCoordinator: (any Navigating)?
    /// web view coordinator
    private var webContentCoordinator: (any Navigating)?
    /// Only needed on Tablet
    private var tabletTabsCoordinator: (any Layouting)?
    /// App window rectangle
    private let windowRectangle: CGRect = {
        CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }()
    /// main app window
    private let window: UIWindow
    /// Not initialized, will be initialized after `TabsListManager`
    /// during tab opening. Used only during tab opening for optimization
    private lazy var previousTabContent: Tab.ContentType = FeatureManager.tabDefaultContentValue().contentType
    /// Not a constant because can't be initialized in init
    private var jsPluginsBuilder: (any JSPluginsSource)?
    
    /// Need to update this navigation delegate each time it changes in router holder
    private weak var siteNavigationDelegate: SiteNavigationDelegate?
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

extension AppCoordinator: CoordinatorOwner {
    func didFinish() {
        // Menu view controller is stored as started which is good
        startedCoordinator = nil
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
        // Probably it is not necessary because this is root
        jsPluginsBuilder = nil
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
        case .toolbar:
            insertToolbar()
        case .dummyView:
            insertDummyView()
        case .linkTags:
            insertLinkTags()
        case .filesGrid:
            insertFilesGrid()
        }
    }
    
    func layout(_ step: OwnLayoutStep) {
        // Could do root layout here instead of view controller
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    func layoutNext(_ step: LayoutStep<SP>) {
        switch step {
        case .viewDidLoad(let subview, _, _, _):
            switch subview {
            case .tabs:
                tabsViewDidLoad()
            case .searchBar:
                searchBarViewDidLoad()
            case .loadingProgress:
                loadingProgressViewDidLoad()
            case .webContentContainer:
                webContentContainerViewDidLoad()
            case .toolbar:
                toolbarViewDidLoad()
            case .dummyView:
                dummyViewDidLoad()
            case .linkTags:
                linkTagsViewDidLoad()
            case .filesGrid:
                filesGridViewDidLoad()
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
        // Link tags coordinator MUST be initialized before Search bar
        // to have a reference to a delegate for it
        linkTagsCoordinator = LinkTagsCoordinator(vcFactory, presenter)
        linkTagsCoordinator?.parent = self
        
        let coordinator: SearchBarCoordinator = .init(vcFactory,
                                                      presenter,
                                                      linkTagsCoordinator,
                                                      self,
                                                      self)
        coordinator.parent = self
        coordinator.start()
        searchBarCoordinator = coordinator
        
        // The easiest way to pass the presenter which is Tablet search bar view controller.
        // Also, need to make sure that search bar coordinator was started before
        // this link tags coordinator to have a view controller initialized in vc factory
        linkTagsCoordinator?.mediaLinksPresenter = vcFactory.createdDeviceSpecificSearchBarVC as? MediaLinksPresenter
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
        linkTagsCoordinator?.start()
    }
    
    func insertToolbar() {
        // swiftlint:disable:next force_unwrapping
        let presenter = startedVC!
        // Link tags coordinator MUST be initialized before this toolbar
        // and it is initialized before Search bar coordinator now
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
    
    func insertTopSites() {
        guard let containerView = webContentContainerCoordinator?.startedView else {
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
        guard let containerView = webContentContainerCoordinator?.startedView else {
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
        guard let containerView = webContentContainerCoordinator?.startedView,
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
    
    // MARK: - view did load
    
    func tabsViewDidLoad() {
        guard isPad else {
            return
        }
        tabletTabsCoordinator?.layout(.viewDidLoad())
    }
    
    func searchBarViewDidLoad() {
        // use specific bottom anchor when it is Tablet layout
        // and the most top view is not a superview but tabs view
        // if it is a Phone layout then topAnchor can be taken
        // easily from presenter
        let topAnchor = tabletTabsCoordinator?.startedView?.bottomAnchor
        searchBarCoordinator?.layout(.viewDidLoad(topAnchor))
    }
    
    func loadingProgressViewDidLoad() {
        let topAnchor = searchBarCoordinator?.startedVC?.controllerView.bottomAnchor
        loadingProgressCoordinator?.layout(.viewDidLoad(topAnchor))
    }
    
    func filesGridViewDidLoad() {
        linkTagsCoordinator?.layoutNext(.viewDidLoad(.filesGrid))
    }
    
    func webContentContainerViewDidLoad() {
        let topAnchor = loadingProgressCoordinator?.startedVC?.controllerView.bottomAnchor
        // Web content bottom border depends on device layout
        // for Phone layout it should be a toolbar,
        // for Tablet layout it should be a bottom dummy view

        // Below used coordinators MUST be started to be able to provide bottom anchors,
        // but it is not possible at this time, so that,
        // bottom dummy or toolbar view should use web content container view bottom anchor
        // MUST be attached later during layout of toolbar or dummy coordinators
        webContentContainerCoordinator?.layout(.viewDidLoad(topAnchor))
    }
    
    func toolbarViewDidLoad() {
        let topAnchor = webContentContainerCoordinator?.startedView?.bottomAnchor
        toolbarCoordinator?.layout(.viewDidLoad(topAnchor, nil))
    }
    
    func dummyViewDidLoad() {
        // top anchor is different on Tablet it is web content container bottom anchor
        // and on Phone it is toolbar bottom anchor
        let topAnchor: NSLayoutYAxisAnchor?
        if isPad {
            // maybe on Tablet it is better just to use super view bottom anchor
            topAnchor = webContentContainerCoordinator?.startedView?.bottomAnchor
        } else {
            topAnchor = toolbarCoordinator?.startedView?.bottomAnchor
        }
        bottomViewCoordinator?.layout(.viewDidLoad(topAnchor))
    }
    
    func linkTagsViewDidLoad() {
        let bottomAnchor: NSLayoutYAxisAnchor?
        if isPad {
            // bottom dummy view top or root view bottom
            // bottomViewCoordinator?.startedView?.topAnchor
            bottomAnchor = startedView?.bottomAnchor
        } else {
            bottomAnchor = toolbarCoordinator?.startedView?.topAnchor
        }
        linkTagsCoordinator?.layout(.viewDidLoad(nil, bottomAnchor))
    }
    
    // MARK: - lifecycle navigation methods
    
    func startMenu(_ model: SiteMenuModel, _ sourceView: UIView, _ sourceRect: CGRect) {
        // swiftlint:disable:next force_unwrapping
        let presenter = vcFactory.createdDeviceSpecificSearchBarVC!
        let coordinator: GlobalMenuCoordinator = .init(vcFactory, presenter, model, sourceView, sourceRect)
        coordinator.parent = self
        coordinator.start()
        startedCoordinator = coordinator
    }
    
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
    
    // MARK: - safe area insets
    
    func dummyViewSafeAreaInsetsDidChange() {
        bottomViewCoordinator?.layout(.viewSafeAreaInsetsDidChange)
    }
    
    // MARK: - did layout subviews
    
    func filesGridViewDidLayoutSubviews() {
        // Files grid view height depends on web content view height,
        // search bar view should still be visible when files grid
        // become visible, that is why we need to calculate good enough
        // height of files grid view
        let containerHeight = webContentContainerCoordinator?.startedView?.bounds.height
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
        menuModel.developerMenuPresenter = self
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
    func openTab(_ content: Tab.ContentType) {
        showNext(.openTab(content))
    }
    
    func layoutSuggestions() {
        // Pass top and bottom anchors and toolbar height
        let topAnchor = searchBarCoordinator?.startedVC?.controllerView.bottomAnchor
        let bottomAnchor: NSLayoutYAxisAnchor?
        if isPad {
            // Probably better to use bottom dummy view anchor
            // bottomViewCoordinator?.startedView?.topAnchor
            bottomAnchor = startedVC?.controllerView.bottomAnchor
        } else {
            // Toolbar is only on Phone layout
            bottomAnchor = toolbarCoordinator?.startedView?.topAnchor
        }
        let toolbarHeight = toolbarCoordinator?.startedView?.bounds.height
        searchBarCoordinator?.layoutNext(.viewDidLoad(.suggestions, topAnchor, bottomAnchor, toolbarHeight))
    }
}

extension AppCoordinator: DeveloperMenuPresenter {
    func emulateLinkTags() {
        // swiftlint:disable:next force_unwrapping
        let url1 = URL(string: "https://www.mozilla.org/media/img/favicons/mozilla/apple-touch-icon.8cbe9c835c00.png")!
        // swiftlint:disable:next force_unwrapping
        let url2 = URL(string: "https://www.opennet.ru/opennet_120.png")!
        let tag1: HTMLVideoTag = .init(srcURL: url1, posterURL: url1, name: "example 1")
        let tag2: HTMLVideoTag = .init(srcURL: url2, posterURL: url2, name: "example 2")
        let tags: [HTMLVideoTag] = [tag1, tag2]
        didReceiveVideoTags(tags)
    }
}
