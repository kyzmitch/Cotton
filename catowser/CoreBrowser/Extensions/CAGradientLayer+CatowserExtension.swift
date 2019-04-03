//
//  CAGradientLayer+CatowserExtension.swift
//  CoreBrowser
//
//  Created by Andrei Ermoshin on 03/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import Foundation

extension CAGradientLayer {
    public static func lightBackgroundGradientLayer(bounds: CGRect, lightTop: Bool = true) -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        let topColor: CGColor = UIColor.white.cgColor
        let bottomColor: CGColor = UIColor.lightGray.cgColor
        if lightTop {
            layer.colors = [topColor, bottomColor]
            layer.locations = [0.0, 1.0]
        } else {
            layer.colors = [bottomColor, topColor]
            layer.locations = [0.0, 1.0]
        }
        return layer
    }
}
