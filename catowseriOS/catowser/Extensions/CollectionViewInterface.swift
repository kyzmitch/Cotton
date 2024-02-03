//
//  CollectionViewInterface.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 05/04/2019.
//  Copyright © 2019 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import Foundation
import UIKit

private struct CollectionViewSizes {
    static let compactNumberOfColumnsThin = 2
    static let numberOfColumnsWide = 3
}

protocol CollectionViewInterface: AnyObject {
    var traitCollection: UITraitCollection { get }
}

extension CollectionViewInterface {
    public var numberOfColumns: Int {
        // iPhone 4-6+ portrait
        if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular {
            return CollectionViewSizes.compactNumberOfColumnsThin
        } else {
            return CollectionViewSizes.numberOfColumnsWide
        }
    }
}
