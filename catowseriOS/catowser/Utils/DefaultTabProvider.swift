//
//  DefaultTabProvider.swift
//  catowser
//
//  Created by Andrei Ermoshin on 01/02/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser
import FeaturesFlagsKit
import CottonBase

final class DefaultTabProvider {
    static let shared = DefaultTabProvider()
    
    let selected: Bool
    
    let blockPopups: Bool = false

    lazy var topSites: [Site] = {
        let array: [Site?]
        let isJsEnabled = FeatureManager.shared.boolValue(of: .javaScriptEnabled)
        let settings: Site.Settings = .init(isPrivate: false,
                                            blockPopups: blockPopups,
                                            isJSEnabled: isJsEnabled,
                                            canLoadPlugins: true)
        let opennet = Site("https://opennet.ru", "OpenNet", settings)
        let yahooFinance = Site("https://finance.yahoo.com", "Yahoo Finance", settings)
        let github = Site("https://github.com", "GitHub", settings)
        #if DEBUG
        let mailToLink = Site("https://www.k8oms.net/links/mailto-link", "k8oms", settings)
        let mapsV1 = Site("https://www.apple.com/maps/", "apple maps", settings)
        array = [opennet, yahooFinance, github, mailToLink, mapsV1]
        #else
        array = [opennet, yahooFinance, github]
        #endif
        return array.compactMap {$0}
    }()
    
    private init() {
        selected = UIDevice.current.userInterfaceIdiom == .pad
    }
}

extension DefaultTabProvider: TabsStates {
    var addPosition: AddedTabPosition {
        FeatureManager.shared.tabAddPositionValue()
    }
    
    var contentState: Tab.ContentType {
        FeatureManager.shared.tabDefaultContentValue().contentType
    }
    
    var addSpeed: TabAddSpeed { .after(.milliseconds(300)) }
    
    var defaultSelectedTabId: UUID { .notPossibleId }
}

private extension UUID {
    static let notPossibleId: UUID = .init(uuid: (0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1))
}
