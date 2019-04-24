//
//  VideoDownloadViewCell.swift
//  catowser
//
//  Created by Andrei Ermoshin on 04/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser

final class VideoDownloadViewCell: DownloadButtonCellView, ReusableItem {
    /// Container for download button which will be added programmatically
    @IBOutlet weak var buttonContainer: UIView!

    static func cellHeight(basedOn cellWidth: CGFloat, _ traitCollection: UITraitCollection) -> CGFloat {

        return cellWidth + Sizes.downloadButtonHeight
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        buttonContainer.addSubview(downloadButton)
        downloadButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor).isActive = true
        downloadButton.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor).isActive = true
        downloadButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor, constant: 1).isActive = true
        downloadButton.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor, constant: 1).isActive = true
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // http://khanlou.com/2018/09/hacking-hit-tests/

        guard isUserInteractionEnabled else { return nil }

        guard !isHidden else { return nil }

        guard alpha >= 0.01 else { return nil }

        guard self.point(inside: point, with: event) else { return nil }

        if downloadButton.point(inside: convert(point, to: downloadButton), with: event) {
            return downloadButton
        }

        for subview in subviews.reversed() {
            let convertedPoint = subview.convert(point, from: self)
            if let candidate = subview.hitTest(convertedPoint, with: event) {
                return candidate
            }
        }

        return super.hitTest(point, with: event)
    }

    private struct Sizes {
        static let downloadButtonHeight: CGFloat = 34.0
    }
}
