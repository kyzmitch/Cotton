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

final class AppCoordinator: Coordinator, CoordinatorOwner {
    var startedCoordinator: Coordinator?
    weak var parent: CoordinatorOwner?
    let vcFactory: ViewControllerFactory
    var startedVC: AnyViewController?
    var presenterVC: AnyViewController?
    
    /// Specific toolbar coordinator which should stay forever
    private var toolbarCoordinator: Coordinator?
    /// App window rectangle
    private let windowRectangle: CGRect = {
        CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }()
    /// main app window
    private let window: UIWindow
    /// Not initialized, will be initialized after `TabsListManager`
    /// during tab opening. Used only during tab opening for optimization
    private lazy var previousTabContent: Tab.ContentType = FeatureManager.tabDefaultContentValue().contentType
    /// The WebView (controller) if browser has at least one
    private weak var currentWebViewController: AnyViewController?
    /// Temporary property, MUST be removed during refactoring
    weak var layoutCoordinator: AppLayoutCoordinator?
    
    init(_ vcFactory: ViewControllerFactory) {
        self.vcFactory = vcFactory
        window = UIWindow(frame: windowRectangle)
    }
    
    func start() {
        startedVC = vcFactory.rootViewController(self)
        window.rootViewController = startedVC?.viewController
        window.makeKeyAndVisible()
        
        TabsListManager.shared.attach(self)
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
    case toolbar(UIView, DonwloadPanelDelegate, GlobalMenuDelegate)
}

extension AppCoordinator: SubviewNavigation {
    typealias SP = MainScreenSubview
    
    func insertNext(_ subview: SP) {
        switch subview {
        case .toolbar(let containerView, let downloadDelegate, let settingsDelegate):
            insertToolbar(containerView, downloadDelegate, settingsDelegate)
        }
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
                       _ downloadDelegate: DonwloadPanelDelegate,
                       _ settingsDelegate: GlobalMenuDelegate) {
        // swiftlint:disable:next force_unwrapping
        let presenter = startedVC!
        let coordinator: MainToolbarCoordinator = .init(vcFactory,
                                                        presenter,
                                                        containerView,
                                                        downloadDelegate,
                                                        settingsDelegate)
        coordinator.parent = self
        coordinator.start()
        toolbarCoordinator = coordinator
    }
    
    // MARK: - Open tab content functions
    
    func open(tabContent: Tab.ContentType) {
        layoutCoordinator?.closeTags()

        switch previousTabContent {
        case .site:
            // need to stop any video/audio on corresponding web view
            // before removing it from parent view controller.
            // on iphones the video is always played in full-screen (probably need to invent workaround)
            // https://webkit.org/blog/6784/new-video-policies-for-ios/
            // "and, on iPhone, the <video> will enter fullscreen when starting playback."
            // on ipads it is played in normal mode, so, this is why need to stop/pause it
            
            // also need to invalidate and cancel all observations
            // in viewDidDisappear, and not in dealloc,
            // because currently web view controller reference
            // stored in reuse manager which probably
            // not needed anymore even with unsolved memory issue when it's
            // a lot of tabs are opened.
            // It is because it's very tricky to save navigation history
            // for reused web view and for some other reasons.
            currentWebViewController?.viewController.removeFromChild()
        case .topSites:
            let topSitesController = vcFactory.topSitesViewController
            topSitesController.viewController.removeFromChild()
        default:
            let blankWebPageController = vcFactory.blankWebPageViewController
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
    
    func openTopSitesTabContent() {
        siteNavigator = nil
        layoutCoordinator.searchBarController.changeState(to: .blankSearch, animated: true)
        let topSitesController = vcFactory.topSitesViewController
        topSitesController.reload(with: DefaultTabProvider.shared.topSites)

        add(asChildViewController: topSitesController.viewController, to: containerView)
        let topSitesView: UIView = topSitesController.controllerView
        topSitesView.translatesAutoresizingMaskIntoConstraints = false
        topSitesView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        topSitesView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        topSitesView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        topSitesView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
    
    func openBlankTabContent() {
        siteNavigator = nil
        layoutCoordinator.searchBarController.changeState(to: .blankSearch, animated: true)

        let blankWebPageController = vcFactory.blankWebPageViewController
        add(asChildViewController: blankWebPageController, to: containerView)
        let blankView: UIView = blankWebPageController.view
        blankView.translatesAutoresizingMaskIntoConstraints = false
        blankView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        blankView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        blankView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        blankView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
    
    func openSiteTabContent(with site: Site) {
        guard let jsPluginsSource = jsPluginsBuilder else {
            assertionFailure("Plugins source is expected to be initialized even if it is empty")
            return
        }
        // need to display progress view before load start
        layoutCoordinator.showProgress(true)
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
}

extension AppCoordinator {
    var toolbarView: UIView? {
        toolbarCoordinator?.startedVC?.controllerView
    }
    
    var toolbarViewController: AnyViewController? {
        toolbarCoordinator?.startedVC
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

        layoutCoordinator.closeTags()
        reloadNavigationElements(withSite)
    }
}
