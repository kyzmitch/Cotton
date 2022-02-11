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

protocol TopSitesInterface {
    func reload(with sites: [Site])
}

final class TopSitesViewController: UIViewController {
    @IBOutlet fileprivate weak var collectionView: UICollectionView!

    fileprivate var source: [Site] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        // this isn't called for Nib associated with single view controller
        // as a File's owner. called only for archives from nib
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.9647058824, alpha: 1)
        collectionView.registerNib(with: SiteCollectionViewCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension TopSitesViewController: TopSitesInterface {
    func reload(with sites: [Site]) {
        source = sites
        guard isViewLoaded else {
            return
        }
        collectionView.reloadData()
    }
}

extension TopSitesViewController: AnyViewController {}

extension TopSitesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return source.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: SiteCollectionViewCell = collectionView.dequeueCell(at: indexPath, type: SiteCollectionViewCell.self)
        guard let site = source[safe: indexPath.row] else {
            return cell
        }
        cell.faviconImageView.layer.cornerRadius = 3
        cell.faviconImageView.layer.masksToBounds = true
        cell.reloadSiteCell(with: site)
        return cell
    }
}

extension TopSitesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return SiteCollectionViewCell.size(for: traitCollection)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(equalInset: 20)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        defer {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        guard let site = source[safe: indexPath.row] else {
            return
        }

        try? TabsListManager.shared.replaceSelected(tabContent: .site(site))
    }
}

extension SiteCollectionViewCell {
    func reloadSiteCell(with site: Site) {
        titleLabel.text = site.title
        if let hqImage = site.highQualityFaviconImage {
            faviconImageView.image = hqImage
            return
        }
        faviconImageView.image = nil

        if #available(iOS 13.0, *) {
            imageURLRequestCancellable?.cancel()
            let useDoH = FeatureManager.boolValue(of: .dnsOverHTTPSAvailable)
            imageURLRequestCancellable = site.fetchFaviconURL(useDoH, dnsClientSubscriber)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { (completion) in
                    switch completion {
                    case .failure:
                        // print("Favicon URL failed for \(site.host.rawValue) \(error.localizedDescription)")
                        break
                    default: break
                    }
                }, receiveValue: { [weak self] (url) in
                    self?.faviconImageView.updateImage(from: .url(url))
                })
        } else {
            let source: ImageSource
            switch (site.faviconURL, site.highQualityFaviconImage) {
            case (let url?, nil):
                source = .url(url)
            case (nil, let image?):
                source = .image(image)
            case (let url?, let image?):
                source = .urlWithPlaceholder(url, image)
            default:
                return
            }
            faviconImageView.updateImage(from: source)
        }
    }
}
