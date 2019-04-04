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
    func setNodes(_ nodes: [InstagramVideoNode])
}

final class FilesGreedViewController: UICollectionViewController {
    static func newFromStoryboard() -> FilesGreedViewController {
        let name = String(describing: self)
        return FilesGreedViewController.instantiateFromStoryboard(name, identifier: name)
    }

    private var backLayer: CAGradientLayer?

    fileprivate var numberOfColumns: Int {
        // iPhone 4-6+ portrait
        if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular {
            return Sizes.compactNumberOfColumnsThin
        } else {
            return Sizes.numberOfColumnsWide
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
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
        static let compactNumberOfColumnsThin = 2
        static let numberOfColumnsWide = 3
        static let margin = CGFloat(15)
    }
}

// MARK: UICollectionViewDataSource
extension FilesGreedViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(at: indexPath, type: VideoFileViewCell.self)
        
        return cell
    }
}

extension FilesGreedViewController: AnyViewController {}

extension FilesGreedViewController: FilesGreedPresenter {
    func setNodes(_ nodes: [InstagramVideoNode]) {

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
