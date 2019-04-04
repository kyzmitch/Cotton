//
//  VideoFileViewCell.swift
//  catowser
//
//  Created by Andrei Ermoshin on 04/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser
import AHDownloadButton

final class VideoFileViewCell: UICollectionViewCell, ReusableItem {
    /// Video preview
    @IBOutlet weak var imageView: UIImageView!
    /// Container for download button which will be added programmatically
    @IBOutlet weak var buttonContainer: UIView!

    static func cellHeight(basedOn cellWidth: CGFloat, _ traitCollection: UITraitCollection) -> CGFloat {

        return cellWidth + Sizes.downloadButtonHeight
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        let downloadButton = AHDownloadButton(frame: .zero)
        downloadButton.translatesAutoresizingMaskIntoConstraints = true
        buttonContainer.addSubview(downloadButton)
    }

    struct Sizes {
        static let downloadButtonHeight: CGFloat = 40.0
    }
}
