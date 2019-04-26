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
    @IBOutlet weak var downloadButton: UIButton! {
        didSet {
            downloadButton.addTarget(self, action: .downloadPressed, for: .touchUpInside)
        }
    }
    /// Video title view
    @IBOutlet weak var titleLabel: UILabel!

    var buttonState: DownloadButtonState = .canDownload {
        didSet {
            switch buttonState {
            case .canDownload:
                <#code#>
            default:
                <#code#>
            }
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
                        self.progressView.progress = Float(progress)
                    case .finished(_):
                        self.buttonState = .downloaded
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
            progressView.progress = 0
            buttonState = .canDownload
        }
    }

    weak var delegate: FileDownloadViewDelegate?

    private var disposable: Disposable?

    deinit {
        disposable?.dispose()
    }

    func setInitialButtonState() {
        progressView.progress = 0
        buttonState = .canDownload
    }

    func setPendingButtonState() {
        progressView.progress = 0
        //downloadButton.state = .pending
    }

    enum DownloadButtonState {
        case canDownload
        case downloading
        case downloaded
    }
}

extension DownloadButtonCellView: ReusableItem {}

extension DownloadButtonCellView: FileDownloadDelegate {
    func didPressOpenFile(withLocal url: URL) {
        delegate?.didRequestOpen(local: url, from: downloadButton)
    }
}

private extension DownloadButtonCellView {
    @objc func downloadButtonPressed() {
        buttonState = .downloading
        viewModel.download()
    }
}

fileprivate extension Selector {
    static let downloadPressed = #selector(DownloadButtonCellView.downloadButtonPressed)
}
