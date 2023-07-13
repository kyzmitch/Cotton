//
//  LinkTagsViewController.swift
//  catowser
//
//  Created by Andrei Ermoshin on 24/03/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser
import CottonPlugins

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

protocol LinkTagsPresenter: AnyObject {
    func setLinks(_ count: Int, for type: LinksType)
    func clearLinks()
}

protocol LinkTagsDelegate: AnyObject {
    func didSelect(type: LinksType, from sourceView: UIView)
}

final class LinkTagsViewController: UICollectionViewController {
    private var linksCounts = [LinksType: Int]()
    private weak var delegate: LinkTagsDelegate?
    
    static func newFromStoryboard(delegate: LinkTagsDelegate?) -> LinkTagsViewController {
        let name = String(describing: self)
        let vc = LinkTagsViewController.instantiateFromStoryboard(name, identifier: name)
        vc.delegate = delegate
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ThemeProvider.shared.setupUnderLinkTags(collectionView)

        // Inset From property must be set to "from Content Inset"
        // in Storyboard of view controller in UICollectionView
        // overwise you will see gap from the top of cells
        let zeroInset: UIEdgeInsets
        if isPad {
            zeroInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        } else {
            zeroInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        collectionView.contentInset = zeroInset

        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            assertionFailure("Collection layout isn't flow")
            return
        }

        flowLayout.sectionInset = zeroInset
        let estimatedSize = CGSize(width: 128, height: .linkTagsHeight)
        flowLayout.estimatedItemSize = estimatedSize
        /* UICollectionViewFlowLayout.automaticSize */
        flowLayout.invalidateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return linksCounts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LinksBadgeView = collectionView.dequeueCell(at: indexPath, type: LinksBadgeView.self)
        for (index, tuple) in linksCounts.enumerated() where index == indexPath.item {
            cell.set(tuple.value, tagName: tuple.key.description)
            break
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for (index, tuple) in linksCounts.enumerated() where index == indexPath.item {
            let cell: LinksBadgeView = collectionView.dequeueCell(at: indexPath, type: LinksBadgeView.self)
            delegate?.didSelect(type: tuple.key, from: cell)
            break
        }
    }
}

fileprivate extension LinksBadgeView {
    func set(_ linksCount: Int, tagName: String) {
        let source = "\(linksCount) \(tagName)"
        tagTypeLabel.text = source
        self.tagTypeLabel.layer.borderWidth = 2
        self.tagTypeLabel.layer.borderColor = #colorLiteral(red: 0.9620149732, green: 0.9620149732, blue: 0.9620149732, alpha: 1)
    }
}

extension LinkTagsViewController: LinkTagsPresenter {
    func setLinks(_ count: Int, for type: LinksType) {
        linksCounts[type] = count
        // no specific index
        collectionView.reloadData()
    }
    
    func clearLinks() {
        linksCounts.removeAll()
        collectionView.reloadData()
    }
}
