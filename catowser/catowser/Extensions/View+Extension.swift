//
//  View+Extension.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/11/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI

extension View {
    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}
