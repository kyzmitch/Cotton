//
//  SiteCollectionViewCell.swift
//  catowser
//
//  Created by Andrei Ermoshin on 06/05/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser
#if canImport(Combine)
import Combine
#endif
import BrowserNetworking

enum ImageViewSizes {
    static let imageHeight: CGFloat = 96
    static let titleHeight: CGFloat = 22
}

final class SiteCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var faviconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @available(iOS 13.0, *)
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
