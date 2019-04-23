//
//  VideoDownloadViewCell.swift
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

final class VideoDownloadViewCell: UICollectionViewCell, ReusableItem {
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

    var viewModel: FileDownloadViewModel! {
        didSet {
            viewModel.delegate = self

            disposable?.dispose()
            disposable = viewModel.stateSignal
                .observe(on: UIScheduler())
                .observeValues { [weak self] state in
                    guard let self = self else { return }
                    switch state {
                    case .initial:
                        self.setInitialButtonState()
                    case .started:
                        self.setPendingButtonState()
                    case .in(let progress):
                        self.downloadButton.progress = progress
                    case .finished(_):
                        self.downloadButton.state = .downloaded
                    case .error(_):
                        self.setInitialButtonState()
                    }
            }
        }
    }

    weak var delegate: FileDownloadViewDelegate?

    private var disposable: Disposable?

    lazy var downloadButton: AHDownloadButton = {
        let btn = AHDownloadButton(frame: .zero)
        btn.isUserInteractionEnabled = true
        btn.delegate = viewModel
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

    deinit {
        disposable?.dispose()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch.view == downloadButton {
                viewModel.downloadButton(downloadButton, tappedWithState: downloadButton.state)
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

fileprivate extension VideoDownloadViewCell {
    func setInitialButtonState() {
        downloadButton.progress = 0
        downloadButton.state = .startDownload
    }

    func setPendingButtonState() {
        downloadButton.progress = 0
        downloadButton.state = .pending
    }
}

extension VideoDownloadViewCell: FileDownloadDelegate {
    func didPressOpenFile(withLocal url: URL) {
        delegate?.open(local: url, from: downloadButton)
    }
}
