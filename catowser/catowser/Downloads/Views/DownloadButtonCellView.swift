//
//  DownloadButtonCellView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 24/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import AHDownloadButton
import ReactiveSwift

class DownloadButtonCellView: UICollectionViewCell {
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch.view == downloadButton {
                viewModel.downloadButton(downloadButton, tappedWithState: downloadButton.state)
                break
            }
        }
    }

    deinit {
        disposable?.dispose()
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

extension DownloadButtonCellView: FileDownloadDelegate {
    func didPressOpenFile(withLocal url: URL) {
        delegate?.open(local: url, from: downloadButton)
    }
}
