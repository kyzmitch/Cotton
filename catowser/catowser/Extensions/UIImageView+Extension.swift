//
//  UIImageView+Extension.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/30/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import AlamofireImage
import UIKit

extension UIImageView {
    func updateImage(fromURL url: URL?, cachedImage: UIImage? = nil) {
        af.cancelImageRequest()
        image = nil
        
        if let favicon = cachedImage {
            image = favicon
            return
        }
        guard let imageURL = url else {
            return
        }
        
        // let imageDownloader = af.imageDownloader ?? UIImageView.af.sharedImageDownloader
        // imageDownloader.addAuthentication(usingCredential: )
        // TODO: replace AlamofireImage with own implementation based just on Alamfore to handle TLS handshake errors
        
        af.setImage(withURL: imageURL,
                    cacheKey: nil,
                    placeholderImage: cachedImage,
                    serializer: nil,
                    filter: nil,
                    progress: nil,
                    progressQueue: .global(qos: .userInteractive),
                    imageTransition: .noTransition,
                    runImageTransitionIfCached: false) { [weak self] (dataResponse) in
                        guard let favicon = dataResponse.value else {
                            return
                        }
                        
                        // TODO: failed to calculate average color
                        let averageColor = favicon.firstPixelColor
                        guard let color = averageColor else {
                            return
                        }
                        
                        self?.backgroundColor = color
        }
    }
}
