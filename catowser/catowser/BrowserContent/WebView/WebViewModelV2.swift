//
//  WebViewModelV2.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/19/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI
import CoreHttpKit

final class WebViewModelV2: ObservableObject {
    /// A reference to JavaScript plugins builder passed from root view
    let jsPluginsBuilder: any JSPluginsSource
    /// External delegate which will be a toolbar view model
    private(set) weak var siteNavigation: SiteExternalNavigationDelegate?
    /// A workaround to be able to update state in view update method
    @Published var stopViewUpdates: Bool
    
    init(_ jsPluginsBuilder: any JSPluginsSource,
         _ siteNavigation: SiteExternalNavigationDelegate?) {
        self.jsPluginsBuilder = jsPluginsBuilder
        self.siteNavigation = siteNavigation
        stopViewUpdates = false
    }
}
