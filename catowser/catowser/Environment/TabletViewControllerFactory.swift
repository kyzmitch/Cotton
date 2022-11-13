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
    init() {}
    
    // MARK: - Tablet methods
    
    func deviceSpecificSearchBarViewController(_ searchBarDelegate: UISearchBarDelegate,
                                               _ downloadDelegate: DonwloadPanelDelegate,
                                               _ settingsDelegate: GlobalMenuDelegate) -> UIViewController? {
        return TabletSearchBarViewController(searchBarDelegate,
                                             settingsDelegate,
                                             downloadDelegate)
    }
    
    func deviceSpecificSearchBarViewController(_ searchBarDelegate: UISearchBarDelegate) -> UIViewController? {
        return nil
    }
    func tabsPreviewsViewController(_ tabsRenderer: TabRendererInterface) -> UIViewController? {
        return nil
    }
    func toolbarViewController(_ tabsRenderer: TabRendererInterface,
                               _ downloadDelegate: DonwloadPanelDelegate,
                               _ settingsDelegate: GlobalMenuDelegate) -> UIViewController? {
        return nil
    }
}
