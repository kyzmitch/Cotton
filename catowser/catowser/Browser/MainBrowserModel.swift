//
//  MainBrowserModel.swift
//  catowser
//
//  Created by Andrey Ermoshin on 14.12.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Combine
import SwiftUI
import JSPlugins

final class MainBrowserModel<C: BrowserContentCoordinators>: ObservableObject {
    /// Max value should be 1.0 because total is equals to that by default
    @Published var websiteLoadProgress: Double
    /// Tells if there is a web view content loading is in progress
    @Published var showProgress: Bool
    /// web view interface
    @Published var webViewInterface: WebViewNavigatable?
    
    weak var coordinatorsInterface: C?
    /// Not a constant because can't be initialized in init
    lazy var jsPluginsBuilder: any JSPluginsSource = {
        JSPluginsBuilder().setBase(self).setInstagram(self)
    }()
    
    init(_ coordinatorsInterface: C?) {
        self.coordinatorsInterface = coordinatorsInterface
        websiteLoadProgress = 0.0
        showProgress = false
    }
}

extension MainBrowserModel: InstagramContentDelegate {
    func didReceiveVideoNodes(_ nodes: [InstagramVideoNode]) {
    }
}

extension MainBrowserModel: BasePluginContentDelegate {
    func didReceiveVideoTags(_ tags: [HTMLVideoTag]) {
    }
}
