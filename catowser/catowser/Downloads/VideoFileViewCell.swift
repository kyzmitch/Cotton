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

final class VideoFileViewCell: UICollectionViewCell, ReusableItem {
    /// Video preview
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.backgroundColor = UIColor.white
        }
    }
    /// Container for download button which will be added programmatically
    @IBOutlet weak var buttonContainer: UIView!

    var previewURL: URL? {
        didSet {
            if let url = previewURL {
                imageView.af_setImage(withURL: url)
            }
        }
    }

    var downloadURL: URL? {
        didSet {
            downloadButton.state = .startDownload
            downloadButton.progress = 0
        }
    }

    private lazy var downloadButton: AHDownloadButton = {
        let btn = AHDownloadButton(frame: .zero)
        btn.isUserInteractionEnabled = true
        btn.delegate = self
        btn.translatesAutoresizingMaskIntoConstraints = false

        btn.startDownloadButtonTitle = NSLocalizedString("ttl_download_button", comment: "The title of download button")
        btn.downloadedButtonTitle = NSLocalizedString("ttl_downloaded_button", comment: "The title when download is complete")

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
        guard let url = downloadURL else {
            downloadButton.progress = 0
            downloadButton.state = .startDownload
            return
        }
        downloadButton.state = .downloading
        let task = URLSession.shared.downloadTask(with: url) { [weak self] (_, response, error) in
            print("Finish: \(response) \(error)")
            self?.downloadButton.state = .downloaded
        }
        task.resume()
    }
    
    func stopDownload() {
        
    }
}

extension VideoFileViewCell: AHDownloadButtonDelegate {
    func downloadButton(_ downloadButton: AHDownloadButton, tappedWithState state: AHDownloadButton.State) {
        switch state {
        case .startDownload:
            downloadButton.progress = 0
            downloadButton.state = .pending
            downloadFile()
            break
        case .pending:
            break
        case .downloading:
            downloadButton.progress = 0
            downloadButton.state = .startDownload
            stopDownload()
        case .downloaded:
            break
        }
    }
}
