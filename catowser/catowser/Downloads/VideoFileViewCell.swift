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
import ReactiveSwift

protocol VideoFileCellDelegate: class {
    func didPressDownload(callback: @escaping (CoreBrowser.FileSaveLocation?) -> Void)
    func didStartDownload(for cell: VideoFileViewCell) -> Downloadable?
    func didPressOpenFile(withLocal url: URL, from cell: VideoFileViewCell)
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
            localDownloadedFileURL = nil
            downloadButton.state = .startDownload
            downloadButton.progress = 0
        }
    }

    weak var delegate: VideoFileCellDelegate?

    fileprivate var localDownloadedFileURL: URL?

    func setupWith(previewURL: URL, downloadURL: URL) {
        self.previewURL = previewURL
        self.downloadURL = downloadURL
    }

    lazy var downloadButton: AHDownloadButton = {
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
        downloadButton.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor).isActive = true
        downloadButton.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor).isActive = true
        downloadButton.topAnchor.constraint(equalTo: buttonContainer.topAnchor, constant: 1).isActive = true
        downloadButton.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor, constant: 1).isActive = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch.view == downloadButton {
                downloadButton(downloadButton, tappedWithState: downloadButton.state)
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

    private struct Sizes {
        static let downloadButtonHeight: CGFloat = 34.0
    }
}

fileprivate extension VideoFileViewCell {
    func download(_ batch: Downloadable, andSaveTo location: CoreBrowser.FileSaveLocation) {
        downloadButton.state = .downloading
        CoreBrowser.DownloadFacade.shared.download(file: batch, saveTo: location)
            .observe(on: QueueScheduler.main)
            .startWithResult { [weak self] (result) in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let value):
                switch value {
                case .progress(let progress):
                    let converted = CGFloat(progress.fractionCompleted)
                    self.downloadButton.progress = converted
                case .complete(let localURL):
                    self.localDownloadedFileURL = localURL
                    self.downloadButton.state = .downloaded
                }
            case .failure(let error):
                print("File download error: \(error)")
                self.setInitialButtonState()
            }
        }
    }
    
    func stopDownload() {
        downloadButton.progress = 0
        downloadButton.state = .startDownload
    }

    func setInitialButtonState() {
        downloadButton.progress = 0
        downloadButton.state = .startDownload
    }

    func setPendingButtonState() {
        downloadButton.progress = 0
        downloadButton.state = .pending
    }
}

extension VideoFileViewCell: AHDownloadButtonDelegate {
    func downloadButton(_ downloadButton: AHDownloadButton, tappedWithState state: AHDownloadButton.State) {
        switch state {
        case .startDownload:
            setPendingButtonState()

            guard let batch = delegate?.didStartDownload(for: self) else {
                return setInitialButtonState()
            }
            self.download(batch, andSaveTo: .sandboxFiles)
        case .pending:
            break
        case .downloading:
            stopDownload()
        case .downloaded:
            guard let url = localDownloadedFileURL else {
                return
            }
            delegate?.didPressOpenFile(withLocal: url, from: self)
            break
        }
    }
}
