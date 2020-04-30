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
        af_cancelImageRequest()
        image = nil
        
        if let favicon = cachedImage {
            image = favicon
            return
        }
        guard let imageURL = url else {
            return
        }
        
        af_setImage(withURL: imageURL,
                    placeholderImage: cachedImage,
                    filter: nil,
                    progress: nil,
                    progressQueue: .main,
                    imageTransition: .crossDissolve(0.5),
                    runImageTransitionIfCached: false) { [weak self] dataResponse in
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
