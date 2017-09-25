//
//  UIConstants.swift
//  catowser
//
//  Created by admin on 20/09/2017.
//  Copyright © 2017 andreiermoshin. All rights reserved.
//

import Foundation
import UIKit

struct UIConstants {
    static public let tabHeight: CGFloat = 40.0
    static public func tabWidth() -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 40.0
        }
        else if UIDevice.current.userInterfaceIdiom == .pad {
            return 180.0
        }
        else {
            print("\(#function): interface not implemented")
            return 180.0
        }
    }
}
