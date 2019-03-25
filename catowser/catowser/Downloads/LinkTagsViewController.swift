//
//  LinkTagsViewController.swift
//  catowser
//
//  Created by Andrei Ermoshin on 24/03/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser

enum LinksType: CustomStringConvertible {
    var description: String {
        switch self {
        case .video:
            return "video"
        case .audio:
            return "audio"
        case .pdf:
            return "pdf"
        case .unrecognized:
            return NSLocalizedString("txt_unknown_link_content_type", comment: "Unknown content from link")
        }
    }

    case video
    case audio
    case pdf
    case unrecognized
}

protocol LinkTagsPresenter: class {
    func add(_ link: URL, for type: LinksType)
    func clearLinks()
}

final class LinkTagsViewController: UICollectionViewController {
    typealias UrlsBox = Box<[URL]>

    fileprivate var dataSource = [LinksType: UrlsBox]()
    
    static func newFromStoryboard() -> LinkTagsViewController {
        return LinkTagsViewController.instantiateFromStoryboard("LinkTagsViewController", identifier: "LinkTagsViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LinksBadgeView = collectionView.dequeueCell(at: indexPath, type: LinksBadgeView.self)
        for (index, tuple) in dataSource.enumerated() where index == indexPath.item {
            cell.set(tuple.value.value.count, tagName: tuple.key.description)
            break
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

fileprivate extension LinksBadgeView {
    func set(_ linksCount: Int, tagName: String) {
        tagTypeLabel.text = "\(linksCount) \(tagName)"
    }
}

extension LinkTagsViewController: AnyViewController {}

extension LinkTagsViewController: LinkTagsPresenter {
    func add(_ link: URL, for type: LinksType) {
        if let urls = dataSource[type] {
            urls.value.append(link)
        } else {
            let box = UrlsBox([link])
            dataSource[type] = box
        }

        // no specific index
        collectionView.reloadData()
    }
    
    func clearLinks() {
        dataSource.removeAll()
        collectionView.reloadData()
    }
}
