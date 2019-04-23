//
//  NamedVideoDownloadViewCell.swift
//  catowser
//
//  Created by Andrei Ermoshin on 23/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser
import AHDownloadButton
import AlamofireImage

final class NamedVideoDownloadViewCell: UICollectionViewCell, ReusableItem {
    /// Video preview
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.backgroundColor = UIColor.white
        }
    }
    /// Container for download button which will be added programmatically
    @IBOutlet weak var buttonContainer: UIView!
    /// Video title view
    @IBOutlet weak var titleLabel: UILabel!

    var previewURL: URL? {
        didSet {
            imageView.af_cancelImageRequest()
            if let url = previewURL {
                imageView.af_setImage(withURL: url)
            } else {
                imageView.image = nil
            }
            downloadButton.state = .startDownload
            downloadButton.progress = 0
        }
    }

    weak var delegate: FileDownloadViewDelegate?

    lazy var downloadButton: AHDownloadButton = {
        let btn = AHDownloadButton(frame: .zero)
        btn.isUserInteractionEnabled = true
        // btn.delegate = self
        btn.translatesAutoresizingMaskIntoConstraints = false

        let beforeTtl = NSLocalizedString("ttl_download_button", comment: "The title of download button")
        btn.startDownloadButtonTitle = beforeTtl
        let afterTtl = NSLocalizedString("ttl_downloaded_button", comment: "The title when download is complete")
        btn.downloadedButtonTitle = afterTtl

        return btn
    }()

    override func awakeFromNib() {
        super.awakeFromNib()

        buttonContainer.addSubview(downloadButton)
        downloadButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor).isActive = true
        downloadButton.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor).isActive = true
        downloadButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor, constant: 1).isActive = true
        downloadButton.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor, constant: 1).isActive = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch.view == downloadButton {
                break
            }
        }
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
}

fileprivate extension NamedVideoDownloadViewCell {
    func setInitialButtonState() {
        downloadButton.progress = 0
        downloadButton.state = .startDownload
    }

    func setPendingButtonState() {
        downloadButton.progress = 0
        downloadButton.state = .pending
    }
}
