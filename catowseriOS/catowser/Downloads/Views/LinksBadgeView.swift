//
//  LinksBadgeView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 24/03/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser

final class LinksBadgeView: UICollectionViewCell, ReusableItem {
    @IBOutlet weak var tagTypeLabel: UILabel! {
        didSet {
            tagTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        }
    }

    // swiftlint:disable:next line_length
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var newFrame = layoutAttributes.frame
        let expectedWidth = size.width + 2 * .tagLabelHorizontalMargin
        newFrame.size.width = expectedWidth
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
}
