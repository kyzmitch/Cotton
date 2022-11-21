//
//  WebContentCoordinator.swift
//  catowser
//
//  Created by Andrei Ermoshin on 11/21/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit
import CoreHttpKit
import CoreBrowser

final class WebContentCoordinator: Coordinator {
    let vcFactory: ViewControllerFactory
    var startedCoordinator: Coordinator?
    weak var parent: CoordinatorOwner?
    var startedVC: AnyViewController?
    weak var presenterVC: AnyViewController?
    
    private weak var siteNavigationDelegate: SiteNavigationChangable?
    private let site: Site
    private let jsPluginsSource: any JSPluginsSource
    private let contentContainerView: UIView
    
    init(_ vcFactory: ViewControllerFactory,
         _ presenter: AnyViewController,
         _ contentContainerView: UIView,
         _ siteNavigationDelegate: SiteNavigationChangable?,
         _ site: Site,
         _ jsPluginsSource: any JSPluginsSource) {
        self.vcFactory = vcFactory
        self.presenterVC = presenter
        self.siteNavigationDelegate = siteNavigationDelegate
        self.contentContainerView = contentContainerView
        self.site = site
        self.jsPluginsSource = jsPluginsSource
    }
    
    func start() {
        let webViewController = try? WebViewsEnvironment.shared.reuseManager.controllerFor(site, jsPluginsSource, self)
        guard let vc = webViewController else {
            assertionFailure("Failed create new web view for tab")
            return
        }
        startedVC = vc
        presenterVC?.viewController.add(asChildViewController: vc.viewController, to: contentContainerView)
        
        let topSitesView: UIView = vc.controllerView
        topSitesView.translatesAutoresizingMaskIntoConstraints = false
        topSitesView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor).isActive = true
        topSitesView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor).isActive = true
        topSitesView.topAnchor.constraint(equalTo: contentContainerView.topAnchor).isActive = true
        topSitesView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor).isActive = true
    }
}

enum WebContentRoute: Route {}

extension WebContentCoordinator: Navigating {
    typealias R = WebContentRoute
    
    func showNext(_ route: R) {}
    
    func stop() {
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
        startedVC?.viewController.removeFromChild()
        parent?.didFinish()
    }
}

extension WebContentCoordinator: SiteExternalNavigationDelegate {
    func didUpdateBackNavigation(to canGoBack: Bool) {
        siteNavigationDelegate?.changeBackButton(to: canGoBack)
    }
    
    func didUpdateForwardNavigation(to canGoForward: Bool) {
        siteNavigationDelegate?.changeForwardButton(to: canGoForward)
    }
    
    func didStartProvisionalNavigation() {
        layoutCoordinator.closeTags()
    }

    func didOpenSiteWith(appName: String) {
        // notify user to remove speicifc application from iOS
        // to be able to use Cotton browser features
    }
    
    func displayProgress(_ progress: Double) {
        webLoadProgressView.setProgress(Float(progress), animated: false)
    }
    
    func showProgress(_ show: Bool) {
        layoutCoordinator.showProgress(show)
        webLoadProgressView.setProgress(0, animated: false)
    }
    
    func updateTabPreview(_ screenshot: UIImage) {
        try? TabsListManager.shared.setSelectedPreview(screenshot)
    }
    
    func openTabMenu(from sourceView: UIView,
                     and sourceRect: CGRect,
                     for host: Host,
                     siteSettings: Site.Settings) {
        let style: MenuModelStyle = .siteMenu(host, siteSettings)
        let menuModel: SiteMenuModel = .init(style, siteNavigationDelegate)
        coordinator?.showNext(.menu(menuModel, sourceView, sourceRect))
    }
}
