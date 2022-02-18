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

final class SiteCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var faviconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @available(iOS 13.0, *)
    lazy var imageURLRequestCancellable: AnyCancellable? = nil
    
    let dnsClientSubscriber: GDNSJsonClientSubscriber = .init()

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    static func size(for traitCollection: UITraitCollection) -> CGSize {
        let imageViewHeight: CGFloat
        if traitCollection.verticalSizeClass == .compact {
            imageViewHeight = 96
        } else if traitCollection.horizontalSizeClass == .compact {
            imageViewHeight = 96
        } else {
            imageViewHeight = 96
        }

        return CGSize(width: imageViewHeight, height: imageViewHeight + 22)
    }
}

extension SiteCollectionViewCell: ReusableItem {}
