//
//  Site+Extension.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/11/19.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import CoreBrowser
import UIKit
import AlamofireImage

extension Site {
    var faviconURL: URL? {
        if FeatureManager.boolValue(of: .dnsOverHTTPSAvailable) {
            return URL(faviconIPInfo: url)
        } else {
            return URL(faviconHost: url.host)
        }
    }
    
    func setFaviconFor(_ imageView: UIImageView) {
        imageView.af_cancelImageRequest()
        imageView.image = nil
        
        if let favicon = faviconImage {
            imageView.image = favicon
        } else {
            guard let imageURL = faviconURL else {
                return
            }
            imageView.af_setImage(withURL: imageURL,
                                  placeholderImage: nil,
                                  filter: nil,
                                  progress: nil,
                                  progressQueue: .main,
                                  imageTransition: .crossDissolve(0.5),
                                  runImageTransitionIfCached: false) { dataResponse in
                guard let favicon = dataResponse.value else {
                    return
                }
                
                // TODO: failed to calculate average color
                let averageColor = favicon.firstPixelColor
                guard let color = averageColor else {
                    return
                }
                
                imageView.backgroundColor = color
            }
        }
    }
}
