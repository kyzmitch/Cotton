//
//  Tab+Extension.swift
//  catowser
//
//  Created by Andrei Ermoshin on 10/18/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CoreBrowser
import UIKit

extension Tab {
    /// Preview image of the site if content is .site
    var preview: UIImage? {
        mutating get {
            if let data = previewData {
                return UIImage(data: data)
            } else {
                return nil
            }
        }
        
        set {
            previewData = newValue?.pngData()
        }
    }
    
    func titleColor(_ selectedId: UUID) -> UIColor {
        if selectedId == id {
            return .lightGrayText
        } else {
            return .darkGrayText
        }
    }

    func backgroundColor(_ selectedId: UUID) -> UIColor {
        if selectedId == id {
            return .superLightGray
        } else {
            return .normallyLightGray
        }
    }

    func tabCurvesColour(_ selectedId: UUID) -> UIColor {
        if selectedId == id {
            return .superLightGray
        } else {
            return .normallyLightGray
        }
    }
    
    var realBackgroundColour: UIColor { UIColor.clear }
}

fileprivate extension UIColor {
    static let superLightGray = UIColor(displayP3Red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
    static let normallyLightGray = UIColor(displayP3Red: 0.71, green: 0.71, blue: 0.71, alpha: 1.0)
    static let darkGrayText = UIColor(displayP3Red: 0.32, green: 0.32, blue: 0.32, alpha: 1.0)
    static let lightGrayText = UIColor(displayP3Red: 0.14, green: 0.14, blue: 0.14, alpha: 1.0)
}
