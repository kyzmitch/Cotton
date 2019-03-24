//
//  LinkTagsViewController.swift
//  catowser
//
//  Created by Andrei Ermoshin on 24/03/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser

enum LinksType: Int /* row number*/ {
    case video = 0
    case audio = 1
    case pdf = 2
    case unrecognized = 3
}

protocol LinkTagsPresenter: class {
    func add(_ link: URL, for type: LinksType)
    func clearLinks()
}

final class LinkTagsViewController: UICollectionViewController {
    
    fileprivate var dataSource = Set<LinksType>()
    
    static func newFromStoryboard() -> LinkTagsViewController {
        return LinkTagsViewController.instantiateFromStoryboard("LinkTagsViewController", identifier: "LinkTagsViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LinksBadgeView = collectionView.dequeueCell(at: indexPath, type: LinksBadgeView.self)
        return cell
    }
}

extension LinkTagsViewController: AnyViewController {}

extension LinkTagsViewController: LinkTagsPresenter {
    func add(_ link: URL, for type: LinksType) {
        
    }
    
    func clearLinks() {
        dataSource.removeAll()
    }
}
