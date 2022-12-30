//
//  BrowserContentModel.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/17/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI
import CoreBrowser

final class BrowserContentModel: ObservableObject {
    /// JS plugins builder reference
    let jsPluginsBuilder: any JSPluginsSource
    
    init(_ jsPluginsBuilder: any JSPluginsSource) {
        self.jsPluginsBuilder = jsPluginsBuilder
    }
}
