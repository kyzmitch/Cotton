//
//  DownloadButtonCellView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 24/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import AlamofireImage
import ReactiveSwift
import CoreBrowser

final class DownloadButtonCellView: UITableViewCell {
    /// Video preview
    @IBOutlet weak var previewImageView: UIImageView! {
        didSet {
            previewImageView.backgroundColor = .white
        }
    }

    @IBOutlet weak var progressView: UIProgressView!

    /// Button to initiate download
    @IBOutlet weak var downloadButton: UIButton!
    /// Video title view
    @IBOutlet weak var titleLabel: UILabel!

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
                        // self.downloadButton.progress = progress
                        self.progressView.progress = Float(progress)
                        break
                    case .finished(_):
                        // self.downloadButton.state = .downloaded
                        break
                    case .error(_):
                        self.setInitialButtonState()
                    }
            }
        }
    }

    var previewURL: URL? {
        didSet {
            previewImageView.af_cancelImageRequest()
            if let url = previewURL {
                previewImageView.af_setImage(withURL: url)
            } else {
                previewImageView.image = nil
            }
            // downloadButton.state = .startDownload
            progressView.progress = 0
        }
    }

    weak var delegate: FileDownloadViewDelegate?

    private var disposable: Disposable?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch.view == downloadButton {
                //viewModel.downloadButton(downloadButton, tappedWithState: downloadButton.state)
                break
            }
        }
    }

    deinit {
        disposable?.dispose()
    }

    func setInitialButtonState() {
        progressView.progress = 0
        //downloadButton.state = .startDownload
    }

    func setPendingButtonState() {
        progressView.progress = 0
        //downloadButton.state = .pending
    }
}

extension DownloadButtonCellView: ReusableItem {}

extension DownloadButtonCellView: FileDownloadDelegate {
    func didPressOpenFile(withLocal url: URL) {
        delegate?.didRequestOpen(local: url, from: downloadButton)
    }
}
