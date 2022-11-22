//
//  TabletViewControllerFactory.swift
//  catowser
//
//  Created by Andrey Ermoshin on 12.11.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import UIKit

/// Implements the operations to create tablet layout product objects.
final class TabletViewControllerFactory: ViewControllerFactory {
    private var searchBarVC: UIViewController?
    private var topSitesVC: (AnyViewController & TopSitesInterface)?
    private var blankVC: UIViewController?
    
    init() {}
    
    var createdDeviceSpecificSearchBarVC: UIViewController? {
        return searchBarVC
    }
    
    var createdToolbaViewController: UIViewController? {
        return nil
    }
    
    // MARK: - Tablet methods
    
    func deviceSpecificSearchBarViewController(_ searchBarDelegate: UISearchBarDelegate,
                                               _ downloadDelegate: DonwloadPanelDelegate,
                                               _ settingsDelegate: GlobalMenuDelegate) -> UIViewController? {
        if let existingVC = searchBarVC {
            return existingVC
        }
        searchBarVC = TabletSearchBarViewController(searchBarDelegate, settingsDelegate, downloadDelegate)
        return searchBarVC
    }
    
    func deviceSpecificSearchBarViewController(_ searchBarDelegate: UISearchBarDelegate) -> UIViewController? {
        return nil
    }
    func tabsPreviewsViewController<C: Navigating>(_ coordinator: C) -> UIViewController? where C.R == TabsScreenRoute {
        return nil
    }
    func toolbarViewController<C: Navigating>(_ downloadDelegate: DonwloadPanelDelegate,
                                              _ settingsDelegate: GlobalMenuDelegate,
                                              _ coordinator: C) -> UIViewController? where C.R == ToolbarRoute {
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
