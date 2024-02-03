//
//  UIImage+CatowserExtensions.swift
//  catowser
//
//  Created by Andrei Ermoshin on 2/12/19.
//  Copyright © 2019 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import UIKit
import CoreImage

public extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    func withRoundCorners(_ cornerRadius: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let rect = CGRect(origin: CGPoint.zero, size: size)
        let context = UIGraphicsGetCurrentContext()
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        
        context?.beginPath()
        context?.addPath(path.cgPath)
        context?.closePath()
        context?.clip()
        
        draw(at: CGPoint.zero)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }

    fileprivate var averageColorImage: CGImage? {
        guard let cgImage = self.cgImage else {
            return nil
        }
        let inputImage = CIImage(cgImage: cgImage)
        guard let avgFilter = CIFilter(name: "CIAreaAverage") else {
            return nil
        }
        avgFilter.setValue(inputImage, forKey: kCIInputImageKey)
        let imageRect = inputImage.extent
        avgFilter.setValue(CIVector(cgRect: imageRect), forKey: kCIInputExtentKey)

        guard let outputImage = avgFilter.outputImage else {
            return nil
        }
        let cgOutput = convertCIImageToCGImage(inputImage: outputImage)
        return cgOutput
    }
    
    fileprivate func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
            return cgImage
        }
        return nil
    }

    var firstPixelColor: UIColor? {
        let point = CGPoint(x: 0, y: 0)
        return averageColorImage?.getPixelColor(pos: point)
    }
    
    static let arropUp = UIImage(systemName: "square.and.arrow.up")
}

fileprivate extension CGImage {
    func getPixelColor(pos: CGPoint) -> UIColor? {
        guard let dataProvider = dataProvider else {
            return nil
        }
        guard let pixelData = dataProvider.data else {
            return nil
        }
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let pixelInfo: Int = ((Int(width) * Int(pos.y)) + Int(pos.x)) * 4

        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
