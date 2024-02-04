//
//  DownloadButtonCellView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 24/04/2019.
//  Copyright © 2019 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import UIKit
import AlamofireImage
import ReactiveSwift
import CoreBrowser

final class DownloadButtonCellView: UITableViewCell {
    fileprivate static let bytesInMegabyte: Int = 1048576 // 1024 * 1024

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

    /// Video title label view
    @IBOutlet weak var titleLabel: UILabel!
    /// Displays filename, can't use title because it's too complicated for file name
    @IBOutlet weak var fileNameLabel: UILabel!
    /// Video size label view
    @IBOutlet weak var resourceSizeLabel: UILabel!

    var buttonState: DownloadButtonState? {
        didSet {
            guard let bs = buttonState else {
                return
            }
            switch bs {
            case .canDownload:
                progressView.progress = 0
                progressView.isHidden = false
                downloadButton.isEnabled = true
            case .downloading:
                downloadButton.isEnabled = false
            case .downloaded:
                progressView.isHidden = true
                downloadButton.isEnabled = true
            }
            downloadButton.setTitle(bs.title, for: .normal)
        }
    }

    var viewModel: FileDownloadViewModel? {
        didSet {
            guard let vm = viewModel else {
                return
            }
            vm.delegate = self
            titleLabel.text = vm.labelText
            setButtonState(toDownloadState: vm.downloadState)

            // subscribe to future changes
            downloadStateDisposable?.dispose()
            downloadStateDisposable = vm.downloadStateSignal
                .observe(on: UIScheduler())
                .observeValues { [weak self] state in
                    self?.setButtonState(toDownloadState: state)
                }
            resourceSizeDisposable?.dispose()
            resourceSizeDisposable = vm.resourceSizeSignal
                .observe(on: UIScheduler())
                .observeValues { [weak self] (bytesCount) in
                    let rounted = bytesCount / Self.bytesInMegabyte
                    let sizeInt = Int(rounted)
                    self?.resourceSizeLabel.text = "\(sizeInt) mb"
                }
        }
    }

    var mediaFilePreviewURL: URL? {
        didSet {
            previewImageView.af.cancelImageRequest()
            if let url = mediaFilePreviewURL {
                previewImageView.af.setImage(withURL: url)
            } else {
                previewImageView.image = nil
            }
        }
    }

    weak var delegate: FileDownloadViewDelegate?

    private var downloadStateDisposable: Disposable?
    private var resourceSizeDisposable: Disposable?

    private func setButtonState(toDownloadState state: DownloadState) {
        switch state {
        case .initial:
            self.buttonState = .canDownload
        case .started:
            self.buttonState = .downloading
        case .in(let progress):
            // .downloading
            self.progressView.progress = Float(progress)
        case .finished(let url):
            self.buttonState = .downloaded(url)
        case .error:
            self.buttonState = .canDownload
            self.viewModel = nil
        }
    }

    deinit {
        downloadStateDisposable?.dispose()
        resourceSizeDisposable?.dispose()
    }

    enum DownloadButtonState {
        case canDownload
        case downloading
        case downloaded(URL)

        var title: String {
            switch self {
            case .canDownload:
                return NSLocalizedString("btn_start_download", comment: "Can start download title")
            case .downloading:
                return NSLocalizedString("btn_downloading", comment: "Button title when download is in progress")
            case .downloaded:
                return NSLocalizedString("btn_downloaded", comment: "Can open or share file")
            }
        }
    }
}

extension DownloadButtonCellView: ReusableItem {}

extension DownloadButtonCellView: FileDownloadDelegate {
    func didPressOpenFile(withLocal url: URL) {
        delegate?.didRequestOpen(local: url, from: self)
    }
}

private extension DownloadButtonCellView {
    @objc func downloadButtonPressed() {
        switch buttonState {
        case .canDownload:
            if let vm = viewModel {
                vm.download()
            } else {
                // This code path was used only when there is more than one
                // video quality option (more than one download link for the same resource)
                // not it is not used
                delegate?.didPressDownload(callback: { [weak self] possibleViewModel in
                    guard let self = self else {
                        print("\(#function) - zomby self")
                        return
                    }
                    self.viewModel = possibleViewModel
                    guard let vm = self.viewModel else {
                        print("selected view model is nil")
                        return
                    }
                    vm.download()
                })
            }
        case .downloaded(let url):
            delegate?.didRequestOpen(local: url, from: self)
        default:
            break
        }
    }
}

fileprivate extension Selector {
    static let downloadPressed = #selector(DownloadButtonCellView.downloadButtonPressed)
}
