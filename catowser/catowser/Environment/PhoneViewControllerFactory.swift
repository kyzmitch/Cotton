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
    private var toolBarVC: UIViewController?
    
    init() {}
    
    func deviceSpecificSearchBarViewController(_ searchBarDelegate: UISearchBarDelegate) -> UIViewController? {
        return SmartphoneSearchBarViewController(searchBarDelegate)
    }
    
    func deviceSpecificSearchBarViewController(_ searchBarDelegate: UISearchBarDelegate,
                                               _ downloadDelegate: DonwloadPanelDelegate,
                                               _ settingsDelegate: GlobalMenuDelegate) -> UIViewController? {
        return nil
    }
    
    func toolbarViewController<C: Navigating>(_ downloadDelegate: DonwloadPanelDelegate,
                                              _ settingsDelegate: GlobalMenuDelegate,
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
}
