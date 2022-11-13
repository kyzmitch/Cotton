//
//  ViewControllerFactory.swift
//  catowser
//
//  Created by Andrey Ermoshin on 12.11.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit
import CoreCatowser

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
    func rootViewController(_ coordinator: RootScreenCoordinator) -> UIViewController
    func searchBarViewController(_ searchBarDelegate: UISearchBarDelegate) -> UIViewController
    var searchSuggestionsViewController: UIViewController { get }
    
    func webViewController(_ viewModel: WebViewModel,
                           _ externalNavigationDelegate: SiteExternalNavigationDelegate) -> UIViewController
    var topSitesViewController: AnyViewController & TopSitesInterface { get }
    var blankWebPageViewController: UIViewController { get }
    
    // MARK: - layout specific methods with optional results
    
    /// WIll return nil on Tablet
    func deviceSpecificSearchBarViewController(_ searchBarDelegate: UISearchBarDelegate) -> UIViewController?
    /// Will return nil on Phone
    func deviceSpecificSearchBarViewController(_ searchBarDelegate: UISearchBarDelegate,
                                               _ downloadDelegate: DonwloadPanelDelegate,
                                               _ settingsDelegate: GlobalMenuDelegate) -> UIViewController?
    /// WIll return nil on Tablet
    func toolbarViewController(_ tabsRenderer: TabRendererInterface,
                               _ downloadDelegate: DonwloadPanelDelegate,
                               _ settingsDelegate: GlobalMenuDelegate) -> UIViewController?
    /// WIll return nil on Tablet
    func tabsPreviewsViewController(_ tabsRenderer: TabRendererInterface) -> UIViewController?
}

extension ViewControllerFactory {
    func rootViewController(_ coordinator: RootScreenCoordinator) -> UIViewController {
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
                           _ externalNavigationDelegate: SiteExternalNavigationDelegate) -> UIViewController {
        let vc: WebViewController = .init(viewModel, externalNavigationDelegate)
        return vc
    }
    
    var topSitesViewController: AnyViewController & TopSitesInterface {
        return TopSitesViewController.newFromNib()
    }
    
    var blankWebPageViewController: UIViewController {
        let vc: BlankWebPageViewController = .init()
        return vc
    }
}
