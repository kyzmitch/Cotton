//
//  MainBrowserModel.swift
//  catowser
//
//  Created by Andrey Ermoshin on 14.12.2022.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Combine
import SwiftUI
import CottonPlugins

final class MainBrowserModel<C: BrowserContentCoordinators>: ObservableObject {
    weak var coordinatorsInterface: C?
    /// Not a constant because can't be initialized in init
    lazy var jsPluginsBuilder: any JSPluginsSource = {
        JSPluginsBuilder().setBase(self).setInstagram(self)
    }()
    
    init(_ coordinatorsInterface: C?) {
        self.coordinatorsInterface = coordinatorsInterface
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
