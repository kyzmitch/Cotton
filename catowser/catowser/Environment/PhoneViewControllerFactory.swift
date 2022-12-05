//
//  PhoneViewControllerFactory.swift
//  catowser
//
//  Created by Andrey Ermoshin on 12.11.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit

/// Implements the operations to create phone layout product objects.
final class PhoneViewControllerFactory: ViewControllerFactory {
    private var searchBarVC: UIViewController?
    private var toolBarVC: UIViewController?
    private var topSitesVC: (AnyViewController & TopSitesInterface)?
    private var blankVC: UIViewController?
    
    init() {}
    
    var createdDeviceSpecificSearchBarVC: UIViewController? {
        return searchBarVC
    }
    
    var createdToolbaViewController: UIViewController? {
        return toolBarVC
    }
    
    // MARK: - Phone methods
    
    func deviceSpecificSearchBarViewController(_ searchBarDelegate: UISearchBarDelegate) -> AnyViewController? {
        if let existingVC = searchBarVC {
            return existingVC
        }
        let vc = SmartphoneSearchBarViewController(searchBarDelegate)
        searchBarVC = vc
        return vc
    }
    
    func deviceSpecificSearchBarViewController(_ searchBarDelegate: UISearchBarDelegate,
                                               _ downloadDelegate: DownloadPanelPresenter?,
                                               _ settingsDelegate: GlobalMenuDelegate?) -> AnyViewController? {
        return nil
    }
    
    func toolbarViewController<C: Navigating>(_ downloadDelegate: DownloadPanelPresenter?,
                                              _ settingsDelegate: GlobalMenuDelegate?,
                                              _ coordinator: C) -> UIViewController? where C.R == ToolbarRoute {
        if let existingVC = toolBarVC {
            return existingVC
        }
        toolBarVC = WebBrowserToolbarController(coordinator, downloadDelegate, settingsDelegate)
        return toolBarVC
    }
    
    func tabsPreviewsViewController<C: Navigating>(_ coordinator: C) -> UIViewController? where C.R == TabsScreenRoute {
        let vc: TabsPreviewsViewController = .init(coordinator)
        return vc
    }
    
    func tabsViewController() -> AnyViewController? {
        return nil
    }
    
    var topSitesViewController: AnyViewController & TopSitesInterface {
        if let existingVC = topSitesVC {
            return existingVC
        }
        let createdVC = TopSitesViewController.newFromNib()
        topSitesVC = createdVC
        return createdVC
    }
    
    var blankWebPageViewController: UIViewController {
        if let existingVC = blankVC {
            return existingVC
        }
        let createdVC: BlankWebPageViewController = .init()
        blankVC = createdVC
        return createdVC
    }
}
