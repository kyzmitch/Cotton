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
    typealias L = PhoneLayout
    
    let layoutMode: PhoneLayout
    
    init(_ layoutMode: PhoneLayout) {
        self.layoutMode = layoutMode
    }
    
    var deviceSpecificSearchBarViewController: UIViewController {
        return SmartphoneSearchBarViewController(layoutMode.searchBarDelegate)
    }
}
