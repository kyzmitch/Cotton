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
import AlamofireImage
import SnapKit

protocol VideoFileCellDelegate: class {
    func didPressDownload(callback: @escaping (CoreBrowser.FileSaveLocation?) -> Void)
}

final class VideoFileViewCell: UICollectionViewCell, ReusableItem {
    /// Video preview
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.backgroundColor = UIColor.white
        }
    }
    /// Container for download button which will be added programmatically
    @IBOutlet weak var buttonContainer: UIView!

    fileprivate var previewURL: URL? {
        didSet {
            if let url = previewURL {
                imageView.af_setImage(withURL: url)
            }
        }
    }

    fileprivate var downloadURL: URL? {
        didSet {
            downloadButton.state = .startDownload
            downloadButton.progress = 0
        }
    }

    weak var delegate: VideoFileCellDelegate?

    func setupWith(previewURL: URL, downloadURL: URL) {
        self.previewURL = previewURL
        self.downloadURL = downloadURL
    }

    private lazy var downloadButton: AHDownloadButton = {
        let btn = AHDownloadButton(frame: .zero)
        btn.isUserInteractionEnabled = true
        btn.delegate = self
        btn.translatesAutoresizingMaskIntoConstraints = false

        let beforeTtl = NSLocalizedString("ttl_download_button", comment: "The title of download button")
        btn.startDownloadButtonTitle = beforeTtl
        let afterTtl = NSLocalizedString("ttl_downloaded_button", comment: "The title when download is complete")
        btn.downloadedButtonTitle = afterTtl

        return btn
    }()

    static func cellHeight(basedOn cellWidth: CGFloat, _ traitCollection: UITraitCollection) -> CGFloat {

        return cellWidth + Sizes.downloadButtonHeight
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        buttonContainer.addSubview(downloadButton)
        downloadButton.snp.makeConstraints { (maker) in
            maker.leading.trailing.equalToSuperview()
            maker.top.equalToSuperview().offset(2)
            maker.bottom.equalToSuperview().offset(2)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch.view == downloadButton {
                downloadButton(downloadButton, tappedWithState: downloadButton.state)
                break
            }
        }
    }

    private struct Sizes {
        static let downloadButtonHeight: CGFloat = 44.0
    }
}

fileprivate extension VideoFileViewCell {
    func downloadFile() {
        guard let _ = downloadURL else {
            downloadButton.progress = 0
            downloadButton.state = .startDownload
            return
        }
        downloadButton.state = .downloading

    }
    
    func stopDownload() {
        downloadButton.progress = 0
        downloadButton.state = .startDownload
    }
}

extension VideoFileViewCell: AHDownloadButtonDelegate {
    func downloadButton(_ downloadButton: AHDownloadButton, tappedWithState state: AHDownloadButton.State) {
        switch state {
        case .startDownload:
            downloadButton.progress = 0
            downloadButton.state = .pending
            delegate?.didPressDownload(callback: { [weak self] (location) in
                guard let self = self else {
                    return
                }
                guard let _ = location else {
                    self.downloadButton.progress = 0
                    self.downloadButton.state = .startDownload
                    return
                }
                self.downloadFile()
            })
        case .pending:
            break
        case .downloading:
            stopDownload()
        case .downloaded:
            break
        }
    }
}
