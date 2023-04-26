//
//  SiteCollectionViewCell.swift
//  catowser
//
//  Created by Andrei Ermoshin on 06/05/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser
import Combine
import BrowserNetworking

enum ImageViewSizes {
    static let imageHeight: CGFloat = 87
    static let titleHeight: CGFloat = 21
    static let spacing: CGFloat = 20
    static let titleFontSize: CGFloat = 10
}

final class SiteCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var faviconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    lazy var imageURLRequestCancellable: AnyCancellable? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    static func size(for traitCollection: UITraitCollection) -> CGSize {
        let imageViewHeight: CGFloat
        if traitCollection.verticalSizeClass == .compact {
            imageViewHeight = ImageViewSizes.imageHeight
        } else if traitCollection.horizontalSizeClass == .compact {
            imageViewHeight = ImageViewSizes.imageHeight
        } else {
            imageViewHeight = ImageViewSizes.imageHeight
        }

        return CGSize(width: imageViewHeight, height: imageViewHeight + ImageViewSizes.titleHeight)
    }
}

extension SiteCollectionViewCell: ReusableItem {}
