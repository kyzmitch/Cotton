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
    typealias L = TabletLayout
    
    let layoutMode: TabletLayout
    
    init(_ layoutMode: TabletLayout) {
        self.layoutMode = layoutMode
    }
    
    var deviceSpecificSearchBarViewController: UIViewController {
        return TabletSearchBarViewController(layoutMode.searchBarDelegate,
                                             layoutMode.settingsDelegate,
                                             layoutMode.downloadDelegate)
    }
}
