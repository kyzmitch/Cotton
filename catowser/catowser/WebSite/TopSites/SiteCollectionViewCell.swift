//
//  SiteCollectionViewCell.swift
//  catowser
//
//  Created by Andrei Ermoshin on 06/05/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser

final class SiteCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    static func size(for traitCollection: UITraitCollection) -> CGSize {
        let imageViewHeight: CGFloat
        if traitCollection.verticalSizeClass == .compact {
            imageViewHeight = 128
        } else if traitCollection.horizontalSizeClass == .compact {
            imageViewHeight = 256
        } else {
            imageViewHeight = 128
        }

        return CGSize(width: imageViewHeight, height: imageViewHeight + 22)
    }
}

extension SiteCollectionViewCell: ReusableItem {}
