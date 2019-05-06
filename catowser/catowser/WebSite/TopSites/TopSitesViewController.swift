//
//  TopSitesViewController.swift
//  catowser
//
//  Created by Andrei Ermoshin on 22/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser

final class TopSitesViewController: UIViewController {
    @IBOutlet fileprivate weak var collectionView: UICollectionView!

    var source: [Site] = []

    override func awakeFromNib() {
        collectionView.registerNib(with: SiteCollectionViewCell.self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
    }
}

extension TopSitesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return source.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SiteCollectionViewCell = collectionView.dequeueCell(at: indexPath, type: SiteCollectionViewCell.self)
        return cell
    }
}

extension TopSitesViewController: UICollectionViewDelegateFlowLayout {

}
