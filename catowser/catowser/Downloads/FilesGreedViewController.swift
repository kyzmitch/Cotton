//
//  FilesGreedViewController.swift
//  catowser
//
//  Created by Andrei Ermoshin on 03/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser
import JSPlugins

protocol FilesGreedPresenter: class {
    func reloadWith(source: TagsSiteDataSource, completion: @escaping (() -> Void))
}

protocol FileDownloadViewDelegate: class {
    func open(local url: URL, from view: UIView)
    func didPressDownload(callback: @escaping (URL?) -> Void)
}

final class FilesGreedViewController: UICollectionViewController, CollectionViewInterface {
    static func newFromStoryboard() -> FilesGreedViewController {
        let name = String(describing: self)
        return FilesGreedViewController.instantiateFromStoryboard(name, identifier: name)
    }

    private var backLayer: CAGradientLayer?

    fileprivate var filesDataSource: TagsSiteDataSource?

    fileprivate var contentMode: CellViewsContentMode = .onlyPreview

    override func viewDidLoad() {
        super.viewDidLoad()

        view.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            assertionFailure("collection layout isn't flow")
            return
        }

        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout.invalidateLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        backLayer?.removeFromSuperlayer()
        backLayer = .lightBackgroundGradientLayer(bounds: view.bounds, lightTop: false)
        collectionView.layer.insertSublayer(backLayer!, at: 0)
    }

    enum CellViewsContentMode {
        case withText
        case onlyPreview
    }
}

fileprivate extension FilesGreedViewController {
    struct Sizes {
        static let margin = CGFloat(10)
    }
}

// MARK: UICollectionViewDataSource
extension FilesGreedViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filesDataSource?.itemsCount ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let resultCell: UICollectionViewCell
        switch contentMode {
        case .onlyPreview:
            let cell = collectionView.dequeueCell(at: indexPath, type: VideoDownloadViewCell.self)
            resultCell = cell
            cell.delegate = self

            switch filesDataSource {
            case .instagram(let nodes)?:
                let node = nodes[indexPath.item]
                cell.viewModel = FileDownloadViewModel(with: node)
                cell.previewURL = node.thumbnailUrl
            case .t4?:
                cell.previewURL = nil
                // for this type we can only load preview and title
                // download URL should be chosen e.g. by using action sheet
                break
            default:
                break
            }
        case .withText:
            let cell = collectionView.dequeueCell(at: indexPath, type: NamedVideoDownloadViewCell.self)
            let cellWidth = cell.bounds.width
            let imageViewWidth = cell.imageView.bounds.width
            cell.titleLabel.preferredMaxLayoutWidth = cellWidth - imageViewWidth
            resultCell = cell
            cell.delegate = self

            switch filesDataSource {
            case .instagram(let nodes)?:
                let node = nodes[indexPath.item]
                cell.viewModel = FileDownloadViewModel(with: node)
                cell.titleLabel.text = node.fileName
                cell.previewURL = node.thumbnailUrl
            case .t4?:
                cell.previewURL = nil
                // for this type we can only load preview and title
                // download URL should be chosen e.g. by using action sheet
                break
            default:
                break
            }
        }

        return resultCell
    }
}

extension FilesGreedViewController: AnyViewController {}

extension FilesGreedViewController: FilesGreedPresenter {
    func reloadWith(source: TagsSiteDataSource, completion: @escaping (() -> Void)) {
        guard filesDataSource != source else {
            completion()
            return
        }
        filesDataSource = source
        contentMode = .withText
        collectionView.reloadData(completion)
    }
}

extension FilesGreedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Sizes.margin
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch contentMode {
        case .onlyPreview:
            let cellWidth = floor((collectionView.bounds.width - Sizes.margin * CGFloat(numberOfColumns + 1)) / CGFloat(numberOfColumns))
            let cellHeight = VideoDownloadViewCell.cellHeight(basedOn: cellWidth, traitCollection)
            return CGSize(width: cellWidth, height: cellHeight)
        case .withText:
            let width = collectionView.bounds.width - Sizes.margin
            return CGSize(width: width, height: 156.0)
        }

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(equalInset: Sizes.margin)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Sizes.margin
    }
}

extension FilesGreedViewController: FileDownloadViewDelegate {
    func open(local url: URL, from view: UIView) {
        let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activity.title = NSLocalizedString("ttl_video_share", comment: "Share video")

        if let popoverPresenter = activity.popoverPresentationController {
            let btnBounds = view.bounds
            let btnOrigin = view.frame.origin
            let rect = CGRect(x: btnOrigin.x,
                              y: btnOrigin.y,
                              width: btnBounds.width,
                              height: btnBounds.height)
            popoverPresenter.sourceView = view
            popoverPresenter.sourceRect = rect
        }
        present(activity, animated: true)
    }

    func didPressDownload(callback: @escaping (URL?) -> Void) {
        let title = NSLocalizedString("ttl_video_quality_selection", comment: "Text to ask about video quality")
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        guard case let .t4(videoContainer)? = filesDataSource else {
            callback(nil)
            return
        }
        for (quality, url) in videoContainer.variants {
            let action = UIAlertAction(title: quality.rawValue, style: .default) { (_) in
                callback(url)
            }
            alert.addAction(action)
        }

        let cancelTtl = NSLocalizedString("ttl_common_cancel", comment: "Button title when need dismiss alert")
        let cancel = UIAlertAction(title: cancelTtl, style: .cancel) { (_) in
            callback(nil)
        }
        alert.addAction(cancel)
        present(alert, animated: true)
    }
}

/// Declaring following properties here, because type and protocol are from different frameworks.
/// So, this place is neutral.
extension InstagramVideoNode: Downloadable {
    public var url: URL {
        return videoUrl
    }
}
