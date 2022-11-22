//
//  ViewControllerFactory.swift
//  catowser
//
//  Created by Andrey Ermoshin on 12.11.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit
import CoreCatowser

/// A workaround protocol to get a reference to a view from root view controller
protocol BrowserContentViewHolder: AnyObject {
    var containerView: UIView { get }
}

/**
 Tried to make view controller factory generic and depend on one generic parameter which
 would be layout type (phone or tablet), but it doesn't give the benefits which are needed, like
 only specific layout can have specific methods which are not needed on another layout.
 
 It has to be stored as `any ViewControllerFactory` and info about specific layout
 is erased.
 
 As a current solution some methods could return nil in concrete factory impl.
 */

/// Declares an interface for operations that create abstract product objects.
/// View controllers factory which doesn't depend on device type (phone or tablet)
protocol ViewControllerFactory: AnyObject {
    func rootViewController(_ coordinator: AppCoordinator) -> AnyViewController & BrowserContentViewHolder

    func searchBarViewController(_ searchBarDelegate: UISearchBarDelegate) -> UIViewController
    var searchSuggestionsViewController: UIViewController { get }
    
    func webViewController(_ viewModel: WebViewModel,
                           _ externalNavigationDelegate: SiteExternalNavigationDelegate) -> WebViewController
    var topSitesViewController: AnyViewController & TopSitesInterface { get }
    var blankWebPageViewController: UIViewController { get }
    var loadingProgressViewController: AnyViewController { get }
    func siteMenuViewController<C: Navigating>(_ model: SiteMenuModel,
                                               _ coordinator: C) -> UIViewController
    where C.R == MenuScreenRoute
    
    // MARK: - layout specific methods with optional results
    
    /// Convinience property to get a reference without input parameters
    var createdDeviceSpecificSearchBarVC: UIViewController? { get }
    /// Convinience property to get a reference without input parameters
    var createdToolbaViewController: UIViewController? { get }
    /// WIll return nil on Tablet
    func deviceSpecificSearchBarViewController(_ searchBarDelegate: UISearchBarDelegate) -> UIViewController?
    /// Will return nil on Phone
    func deviceSpecificSearchBarViewController(_ searchBarDelegate: UISearchBarDelegate,
                                               _ downloadDelegate: DonwloadPanelDelegate,
                                               _ settingsDelegate: GlobalMenuDelegate) -> UIViewController?
    /// WIll return nil on Tablet. Should re-create tabs every time to update them
    func toolbarViewController<C: Navigating>(_ downloadDelegate: DonwloadPanelDelegate,
                                              _ settingsDelegate: GlobalMenuDelegate,
                                              _ coordinator: C) -> UIViewController? where C.R == ToolbarRoute
    /// WIll return nil on Tablet
    func tabsPreviewsViewController<C: Navigating>(_ coordinator: C) -> UIViewController? where C.R == TabsScreenRoute
}

extension ViewControllerFactory {
    func rootViewController(_ coordinator: AppCoordinator) -> AnyViewController & BrowserContentViewHolder {
        let vc: MainBrowserViewController = .init(coordinator)
        return vc
    }
    
    func searchBarViewController(_ searchBarDelegate: UISearchBarDelegate) -> UIViewController {
        let vc: SearchBarBaseViewController = .init(searchBarDelegate)
        return vc
    }
    
    var searchSuggestionsViewController: UIViewController {
        // It seems it should be computed property
        // to allow app. to use different view model
        // based on current feature flag's value
        let vc: SearchSuggestionsViewController = .init()
        return vc
    }
    
    func webViewController(_ viewModel: WebViewModel,
                           _ externalNavigationDelegate: SiteExternalNavigationDelegate) -> WebViewController {
        let vc: WebViewController = .init(viewModel, externalNavigationDelegate)
        return vc
    }
    
    func siteMenuViewController<C: Navigating>(_ model: SiteMenuModel, _ coordinator: C) -> UIViewController
    where C.R == MenuScreenRoute {
        let vc: SiteMenuViewController = .init(model, coordinator)
        return vc
    }
    
    var loadingProgressViewController: AnyViewController {
        let vc: LoadingProgressViewController = .init()
        return vc
    }
}
