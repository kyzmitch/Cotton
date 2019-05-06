//
//  TopSitesViewController.swift
//  catowser
//
//  Created by Andrei Ermoshin on 22/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser
import AlamofireImage

final class TopSitesViewController: UIViewController {
    @IBOutlet fileprivate weak var collectionView: UICollectionView!

    var source: [Site] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    override func awakeFromNib() {
        collectionView.registerNib(with: SiteCollectionViewCell.self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension TopSitesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return source.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SiteCollectionViewCell = collectionView.dequeueCell(at: indexPath, type: SiteCollectionViewCell.self)
        guard let site = source[safe: indexPath.row] else {
            return cell
        }
        cell.reload(with: site)
        return cell
    }
}

extension TopSitesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return SiteCollectionViewCell.size(for: traitCollection)
    }
}

extension SiteCollectionViewCell {
    func reload(with site: Site) {
        imageView.af_cancelImageRequest()
        titleLabel.text = site.title
        imageView.af_setImage(withURL: site.faviconURL)
    }
}
