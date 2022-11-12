//
//  ViewControllerFactory.swift
//  catowser
//
//  Created by Andrey Ermoshin on 12.11.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit
import CoreCatowser

protocol LayoutMode {
    var searchBarDelegate: UISearchBarDelegate { get }
    var settingsDelegate: GlobalMenuDelegate { get }
    var downloadDelegate: DonwloadPanelDelegate { get }
}

struct PhoneLayout: LayoutMode {
    let searchBarDelegate: UISearchBarDelegate
    let settingsDelegate: GlobalMenuDelegate
    let downloadDelegate: DonwloadPanelDelegate
    let tabsRenderer: TabRendererInterface
}

struct TabletLayout: LayoutMode {
    let searchBarDelegate: UISearchBarDelegate
    let settingsDelegate: GlobalMenuDelegate
    let downloadDelegate: DonwloadPanelDelegate
}

/// Declares an interface for operations that create abstract product objects.
/// View controllers factory which doesn't depend on device type (phone or tablet)
protocol ViewControllerFactory: AnyObject {
    associatedtype L: LayoutMode
    var layoutMode: L { get }
    
    var rootViewController: UIViewController { get }
    /// Can be different for phone and tablet
    var deviceSpecificSearchBarViewController: UIViewController { get }
    var searchBarViewController: UIViewController { get }
    
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
    
    var searchBarViewController: UIViewController {
        let vc: SearchBarBaseViewController = .init(layoutMode.searchBarDelegate)
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

extension ViewControllerFactory where L == PhoneLayout {
    func toolbarViewController(_ presenter: TabRendererInterface) -> UIViewController {
        let router = ToolbarRouter(presenter: presenter)
        let toolbar = WebBrowserToolbarController(router,
                                                  layoutMode.downloadDelegate,
                                                  layoutMode.settingsDelegate)
        return toolbar
    }

    var tabsPreviewsViewController: UIViewController {
        let router = TabsPreviewsRouter(presenter: layoutMode.tabsRenderer)
        let vc: TabsPreviewsViewController = .init(router)
        return vc
    }
}
