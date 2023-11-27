//
//  WebViewModelV2.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/19/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CottonBase
import CottonPlugins

final class WebViewModelV2 {
    /// A reference to JavaScript plugins builder passed from root view
    let jsPluginsBuilder: any JSPluginsSource
    /// External delegate which will be a toolbar view model
    private(set) weak var siteNavigation: SiteExternalNavigationDelegate?
    
    init(_ jsPluginsBuilder: any JSPluginsSource,
         _ siteNavigation: SiteExternalNavigationDelegate?) {
        self.jsPluginsBuilder = jsPluginsBuilder
        self.siteNavigation = siteNavigation
    }
}
