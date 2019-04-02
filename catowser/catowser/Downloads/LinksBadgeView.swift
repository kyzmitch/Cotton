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
    @IBOutlet weak var tagTypeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.bounds = bounds
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        tagTypeLabel.layer.cornerRadius = tagTypeLabel.bounds.size.height / 2
        tagTypeLabel.clipsToBounds = true
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var newFrame = layoutAttributes.frame
        let expectedWidth = size.width + 2 * UIConstants.tagLabelHorizontalMargin
        newFrame.size.width = expectedWidth
        layoutAttributes.frame = newFrame
        return layoutAttributes
    }
}
