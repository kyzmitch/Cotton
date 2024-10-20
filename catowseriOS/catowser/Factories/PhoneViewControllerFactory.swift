//
//  PhoneViewControllerFactory.swift
//  catowser
//
//  Created by Andrey Ermoshin on 12.11.2022.
//  Copyright © 2022 Cotton (former Catowser). All rights reserved.
//

import FeaturesFlagsKit
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

    func deviceSpecificSearchBarViewController(_ searchBarDelegate: UISearchBarDelegate?,
                                               _ uiFramework: UIFrameworkType) -> AnyViewController? {
        if let existingVC = searchBarVC {
            return existingVC
        }
        let vc = SmartphoneSearchBarViewController(searchBarDelegate, uiFramework)
        searchBarVC = vc
        return vc
    }

    func deviceSpecificSearchBarViewController(_ searchBarDelegate: UISearchBarDelegate?,
                                               _ downloadDelegate: DownloadPanelPresenter?,
                                               _ settingsDelegate: GlobalMenuDelegate?,
                                               _ uiFramework: UIFrameworkType) -> AnyViewController? {
        return nil
    }

    func toolbarViewController<C: Navigating>(_ downloadDelegate: DownloadPanelPresenter?,
                                              _ settingsDelegate: GlobalMenuDelegate?,
                                              _ coordinator: C?,
                                              // swiftlint:disable:next line_length
                                              _ presenter: AnyViewController?) -> UIViewController? where C.R == ToolbarRoute {
        if let existingVC = toolBarVC {
            return existingVC
        }
        let vc = BrowserToolbarController(
            coordinator,
            downloadDelegate,
            settingsDelegate,
            FeatureManager.shared
        )
        vc.presenter = presenter
        toolBarVC = vc
        return toolBarVC
    }

    func tabsPreviewsViewController<C: Navigating>(
        _ coordinator: C,
        _ viewModel: TabsPreviewsViewModel
    ) -> UIViewController? where C.R == TabsScreenRoute {
        let vc: TabsPreviewsViewController = .init(
            coordinator,
            viewModel,
            FeatureManager.shared
        )
        return vc
    }

    func tabsViewController(_ vm: AllTabsViewModel) -> AnyViewController? {
        return nil
    }

    func topSitesViewController<C: Navigating>(_ coordinator: C?) -> AnyViewController & TopSitesInterface
    where C.R == TopSitesRoute {
        if let existingVC = topSitesVC {
            return existingVC
        }
        let bundle = Bundle(for: TopSitesViewController<C>.self)
        let createdVC = TopSitesViewController<C>(nibName: "TopSitesViewController", bundle: bundle)
        createdVC.coordinator = coordinator
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
