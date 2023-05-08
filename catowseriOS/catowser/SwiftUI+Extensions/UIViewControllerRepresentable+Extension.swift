//
//  UIViewControllerRepresentable+Extension.swift
//  catowser
//
//  Created by Andrei Ermoshin on 4/30/23.
//  Copyright © 2023 andreiermoshin. All rights reserved.
//

import SwiftUI

protocol CatowserUIVCRepresentable: UIViewControllerRepresentable {
    var vcFactory: ViewControllerFactory { get }
}

extension CatowserUIVCRepresentable {
    var vcFactory: ViewControllerFactory {
        ViewsEnvironment.shared.vcFactory
    }
}
