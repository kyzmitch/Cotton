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
    init() {}
    
    func deviceSpecificSearchBarViewController(_ searchBarDelegate: UISearchBarDelegate) -> UIViewController? {
        return SmartphoneSearchBarViewController(searchBarDelegate)
    }
    
    func deviceSpecificSearchBarViewController(_ searchBarDelegate: UISearchBarDelegate,
                                               _ downloadDelegate: DonwloadPanelDelegate,
                                               _ settingsDelegate: GlobalMenuDelegate) -> UIViewController? {
        return nil
    }
    
    func toolbarViewController(_ tabsRenderer: TabRendererInterface,
                               _ downloadDelegate: DonwloadPanelDelegate,
                               _ settingsDelegate: GlobalMenuDelegate) -> UIViewController? {
        let router = ToolbarRouter(presenter: tabsRenderer)
        let toolbar = WebBrowserToolbarController(router,
                                                  downloadDelegate,
                                                  settingsDelegate)
        return toolbar
    }
    
    func tabsPreviewsViewController(_ tabsRenderer: TabRendererInterface) -> UIViewController? {
        let router = TabsPreviewsRouter(presenter: tabsRenderer)
        let vc: TabsPreviewsViewController = .init(router)
        return vc
    }
}
