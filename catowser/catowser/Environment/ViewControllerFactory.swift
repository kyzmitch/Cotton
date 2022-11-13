//
//  ViewControllerFactory.swift
//  catowser
//
//  Created by Andrey Ermoshin on 12.11.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit
import CoreCatowser

protocol LayoutMode {}
struct PhoneLayout: LayoutMode {}
struct TabletLayout: LayoutMode {}

/// Declares an interface for operations that create abstract product objects.
/// View controllers factory which doesn't depend on device type (phone or tablet)
protocol ViewControllerFactory: AnyObject {
    associatedtype Layout: LayoutMode
    var layoutMode: Layout { get }
    
    var rootViewController: UIViewController { get }
    func searchBarViewController(_ searchBarDelegate: UISearchBarDelegate) -> UIViewController
    var searchSuggestionsViewController: UIViewController { get }
    
    func webViewController(_ viewModel: WebViewModel,
                           _ externalNavigationDelegate: SiteExternalNavigationDelegate) -> UIViewController
    var topSitesViewController: AnyViewController & TopSitesInterface { get }
    var blankWebPageViewController: UIViewController { get }
}

extension ViewControllerFactory {
    var rootViewController: UIViewController {
        let vc: MainBrowserViewController = .init()
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

extension ViewControllerFactory where Layout == PhoneLayout {
    func toolbarViewController(_ tabsRenderer: TabRendererInterface,
                               _ downloadDelegate: DonwloadPanelDelegate,
                               _ settingsDelegate: GlobalMenuDelegate) -> UIViewController {
        let router = ToolbarRouter(presenter: tabsRenderer)
        let toolbar = WebBrowserToolbarController(router,
                                                  downloadDelegate,
                                                  settingsDelegate)
        return toolbar
    }

    func tabsPreviewsViewController(_ tabsRenderer: TabRendererInterface) -> UIViewController {
        let router = TabsPreviewsRouter(presenter: tabsRenderer)
        let vc: TabsPreviewsViewController = .init(router)
        return vc
    }
    
    func deviceSpecificSearchBarViewController(_ searchBarDelegate: UISearchBarDelegate) -> UIViewController {
        return SmartphoneSearchBarViewController(searchBarDelegate)
    }
}

extension ViewControllerFactory where Layout == TabletLayout {
    func deviceSpecificSearchBarViewController(_ searchBarDelegate: UISearchBarDelegate,
                                               _ downloadDelegate: DonwloadPanelDelegate,
                                               _ settingsDelegate: GlobalMenuDelegate) -> UIViewController {
        return TabletSearchBarViewController(searchBarDelegate,
                                             settingsDelegate,
                                             downloadDelegate)
    }
}
