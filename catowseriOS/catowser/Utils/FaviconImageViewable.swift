//
//  FaviconImageViewable.swift
//  catowser
//
//  Created by Andrei Ermoshin on 7/17/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import UIKit
import CottonBase
import FeaturesFlagsKit
import Combine

protocol FaviconImageViewable: AnyObject {
    var faviconImageView: UIImageView { get }
    var imageURLRequestCancellable: AnyCancellable? { get set }
    
    func reloadImageWith(_ site: Site, _ asyncApi: AsyncApiType, _ useDoH: Bool)
}

extension FaviconImageViewable {
    func reloadImageWith(_ site: Site, _ asyncApi: AsyncApiType, _ useDoH: Bool) {
        switch asyncApi {
        case .reactive, .asyncAwait:
            let source: ImageSource
            // TODO: do a DNS request when useDoH is true
            switch (site.faviconURL(useDoH), site.favicon()) {
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
        case .combine:
            let subscriber = HttpEnvironment.shared.dnsClientSubscriber

            imageURLRequestCancellable?.cancel()
            imageURLRequestCancellable = site.fetchFaviconURL(useDoH, subscriber)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { (completion) in
                    switch completion {
                    case .failure:
                        break
                    default:
                        break
                    }
                }, receiveValue: { [weak self] (url) in
                    self?.faviconImageView.updateImage(from: .url(url))
                })
        }
    }
}
