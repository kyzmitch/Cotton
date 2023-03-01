//
//  Color+Extension.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/13/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI

extension Color {
    static let phoneToolbarColor: Color = {
        let uiKitColor = #colorLiteral(red: 0.9647058824, green: 0.9647058824, blue: 0.9647058824, alpha: 1)
        return .init(uiKitColor)
    }()
}
