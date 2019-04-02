//
//  LinkTagsViewController.swift
//  catowser
//
//  Created by Andrei Ermoshin on 24/03/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser
import JSPlugins

enum LinksType: CustomStringConvertible {
    var description: String {
        switch self {
        case .video:
            return NSLocalizedString("txt_video_tag", comment: "")
        case .audio:
            return NSLocalizedString("txt_audio_tag", comment: "")
        case .pdf:
            return NSLocalizedString("txt_pdf_tag", comment: "")
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
    func setLinks(_ count: Int, for type: LinksType)
    func clearLinks()
}

final class LinkTagsViewController: UICollectionViewController {
    fileprivate var dataSource = [LinksType: Int]()
    
    static func newFromStoryboard() -> LinkTagsViewController {
        let name = String(describing: self)
        return LinkTagsViewController.instantiateFromStoryboard(name, identifier: name)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)

        // Inset From property must be set to "from Content Inset"
        // in Storyboard of view controller in UICollectionView
        // overwise you will see gap from the top of cells
        let zeroInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.contentInset = zeroInset

        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            assertionFailure("collection layout isn't flow")
            return
        }

        flowLayout.sectionInset = zeroInset
        let estimatedSize = CGSize(width: 128, height: UIConstants.linkTagsHeight)
        flowLayout.estimatedItemSize = estimatedSize /* UICollectionViewFlowLayout.automaticSize */
        flowLayout.invalidateLayout()
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
            cell.set(tuple.value, tagName: tuple.key.description)
            break
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension LinkTagsViewController: UICollectionViewDelegateFlowLayout {

}

fileprivate extension LinksBadgeView {
    func set(_ linksCount: Int, tagName: String) {
        let source = "\(linksCount) \(tagName)"
        tagTypeLabel.text = source
    }
}

extension LinkTagsViewController: AnyViewController {}

extension LinkTagsViewController: LinkTagsPresenter {
    func setLinks(_ count: Int, for type: LinksType) {
        dataSource[type] = count
        // no specific index
        collectionView.reloadData()
    }
    
    func clearLinks() {
        dataSource.removeAll()
        collectionView.reloadData()
    }
}
