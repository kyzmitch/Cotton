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
    func setInstagramVideo(_ nodes: [InstagramVideoNode])
}

final class FilesGreedViewController: UICollectionViewController, CollectionViewInterface {
    static func newFromStoryboard() -> FilesGreedViewController {
        let name = String(describing: self)
        return FilesGreedViewController.instantiateFromStoryboard(name, identifier: name)
    }

    private var backLayer: CAGradientLayer?

    /// Array with objects to store URLs for Instagram resources
    private var instagramVideos = [InstagramVideoNode]()

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
        return instagramVideos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(at: indexPath, type: VideoFileViewCell.self)
        cell.delegate = self
        let node = instagramVideos[indexPath.item]
        cell.setupWith(previewURL: node.thumbnailUrl, downloadURL: node.videUrl)
        return cell
    }
}

extension FilesGreedViewController: AnyViewController {}

extension FilesGreedViewController: FilesGreedPresenter {
    func setInstagramVideo(_ nodes: [InstagramVideoNode]) {
        instagramVideos = nodes
        collectionView.reloadData()
    }
}

extension FilesGreedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Sizes.margin
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = floor((collectionView.bounds.width - Sizes.margin * CGFloat(numberOfColumns + 1)) / CGFloat(numberOfColumns))
        let cellHeight = VideoFileViewCell.cellHeight(basedOn: cellWidth, traitCollection)
        return CGSize(width: cellWidth, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(equalInset: Sizes.margin)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Sizes.margin
    }
}

extension FilesGreedViewController: VideoFileCellDelegate {
    func didPressOpenFile(withLocal url: URL, from cell: VideoFileViewCell) {
        let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activity.title = NSLocalizedString("ttl_video_share", comment: "Share video")

        if let popoverPresenter = activity.popoverPresentationController {
            let rect = CGRect(x: cell.frame.origin.x,
                              y: cell.frame.origin.y,
                              width: cell.bounds.width,
                              height: cell.bounds.height)
            popoverPresenter.sourceView = cell
            popoverPresenter.sourceRect = rect
        }
        present(activity, animated: true)
    }

    @available(*, deprecated, message: "Usage of Photo Gallery for media files from internet probably isn't allowed")
    func didPressDownload(callback: @escaping (CoreBrowser.FileSaveLocation?) -> Void) {
        let title = NSLocalizedString("txt_where_save", comment: "Text to ask where need to save the file")
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        let sandBoxTitle = NSLocalizedString("txt_app_sandbox", comment: "Application sandbox which is visible using Files.app")
        let sandBox = UIAlertAction(title: sandBoxTitle, style: .default) { (_) in
            callback(.sandboxFiles)
        }
        alert.addAction(sandBox)
        let galleryTitle = NSLocalizedString("txt_gallery", comment: "iOS Gallery which can be checked using Photos.app")
        let gallery = UIAlertAction(title: galleryTitle, style: .default) { (_) in
            callback(.globalGallery)
        }
        alert.addAction(gallery)
        let cancelTtl = NSLocalizedString("ttl_common_cancel", comment: "Button title when need dismiss alert")
        let cancel = UIAlertAction(title: cancelTtl, style: .cancel) { (_) in
            callback(nil)
        }
        alert.addAction(cancel)
        present(alert, animated: true)
    }

    func didStartDownload(for cell: VideoFileViewCell) -> Downloadable? {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return nil
        }

        let node = instagramVideos[indexPath.item]
        return node
    }
}

/// Declaring following properties here, because type and protocol are from different frameworks.
/// So, this place is neutral.
extension InstagramVideoNode: Downloadable {
    public var url: URL {
        return videUrl
    }
}
