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
    var presenterVC: AnyViewController?
    
    /// Specific toolbar coordinator which should stay forever
    private var toolbarCoordinator: Coordinator?
    /// Progress view coordinator, TODO: needs to be replaced with base protocol
    private var loadingProgressCoordinator: LoadingProgressCoordinator?
    /// Coordinator for inserted child view controller
    private var topSitesCoordinator: (any Navigating)?
    /// blank content vc
    private var blankContentCoordinator: (any Navigating)?
    /// web view coordinator
    private var webContentCoordinator: (any Navigating)?
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
        if let layoutPresenter = vc as? LinksRouterPresenter {
            layoutCoordinator = AppLayoutCoordinator(viewController: layoutPresenter)
        }
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
    case toolbar(UIView, DonwloadPanelDelegate)
    case openTab(Tab.ContentType)
    case loadingProgress
}

extension AppCoordinator: SubviewNavigation {
    typealias SP = MainScreenSubview
    
    func insertNext(_ subview: SP) {
        switch subview {
        case .toolbar(let containerView, let downloadDelegate):
            insertToolbar(containerView, downloadDelegate)
        case .openTab(let content):
            open(tabContent: content)
        case .loadingProgress:
            insertLoadingProgress()
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
        layoutCoordinator?.openTagsFor(instagram: nodes)
        reloadNavigationElements(true, downloadsAvailable: true)
    }
}

extension AppCoordinator: BasePluginContentDelegate {
    func didReceiveVideoTags(_ tags: [HTMLVideoTag]) {
        layoutCoordinator?.openTagsFor(html: tags)
        reloadNavigationElements(true, downloadsAvailable: true)
    }
}

private extension AppCoordinator {
    // MARK: - just private navigation functions
    
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
    
    func insertToolbar(_ containerView: UIView,
                       _ downloadDelegate: DonwloadPanelDelegate) {
        // swiftlint:disable:next force_unwrapping
        let presenter = startedVC!
        let coordinator: MainToolbarCoordinator = .init(vcFactory,
                                                        presenter,
                                                        containerView,
                                                        downloadDelegate,
                                                        self)
        coordinator.parent = self
        coordinator.start()
        toolbarCoordinator = coordinator
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
        layoutCoordinator?.closeTags()

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
            layoutCoordinator?.showProgress(true)
            insertWebTab(site)
        case .topSites:
            siteNavigator = nil
            layoutCoordinator?.searchBarController.changeState(to: .blankSearch, animated: true)
            insertTopSites()
        default:
            siteNavigator = nil
            layoutCoordinator?.searchBarController.changeState(to: .blankSearch, animated: true)
            insertBlankTab()
        }

        previousTabContent = tabContent
    }
    
    func insertLoadingProgress() {
        // swiftlint:disable:next force_unwrapping
        let presenter = startedVC!
        let coordinator: LoadingProgressCoordinator = .init(vcFactory, presenter)
        coordinator.parent = self
        coordinator.start()
        loadingProgressCoordinator = coordinator
    }
}

extension AppCoordinator {
    var toolbarView: UIView? {
        toolbarCoordinator?.startedVC?.controllerView
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

        layoutCoordinator?.closeTags()
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
        layoutCoordinator?.closeTags()
    }
    
    func didLoadingProgressChange(_ progress: Float) {
        loadingProgressCoordinator?.insertNext(.setProgress(progress, false))
    }
    
    func didProgress(show: Bool) {
        layoutCoordinator?.showProgress(show)
        loadingProgressCoordinator?.insertNext(.setProgress(0, false))
    }
}
