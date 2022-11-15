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
    
    func toolbarViewController(_ downloadDelegate: DonwloadPanelDelegate,
                               _ settingsDelegate: GlobalMenuDelegate,
                               _ coordinator: MainToolbarCoordinator) -> UIViewController? {
        if let existingVC = toolBarVC {
            return existingVC
        }
        toolBarVC = WebBrowserToolbarController(coordinator, downloadDelegate, settingsDelegate)
        return toolBarVC
    }
    
    func tabsPreviewsViewController(_ coordinator: Coordinator) -> UIViewController? {
        let vc: TabsPreviewsViewController = .init(coordinator)
        return vc
    }
}
