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
        
        // https://github.com/Alamofire/AlamofireImage/issues/134#issuecomment-245177689
        // Can't solve image loading for URLs with invalid SSL certificate
        // because with AlamofireImage it's not possible to update evaluators
        // for ServerTrustManager, because it is required to update Session as well and
        // which can't be done when more than one image downloads are happening in one time.
        //  As an alternative, it's possible to reimplement image downloading based on Alamofire
        // but it requires too much work.
        //  Firefox for iOS doesn't load favicons for URLs with invalid certificates.
        
        // swiftlint:disable:next line_length
        af.setImage(withURL: imageURL, placeholderImage: cachedImage, progressQueue: .global(qos: .userInteractive), imageTransition: .noTransition, runImageTransitionIfCached: false) { [weak self] (dataResponse) in
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
