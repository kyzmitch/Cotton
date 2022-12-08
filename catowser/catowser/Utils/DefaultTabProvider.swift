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
import CoreHttpKit

final class DefaultTabProvider {
    static let shared = DefaultTabProvider()
    
    let selected: Bool
    
    let blockPopups: Bool = false

    lazy var topSites: [Site] = {
        let array: [Site?]
        let isJsEnabled = FeatureManager.boolValue(of: .javaScriptEnabled)
        let settings: Site.Settings = .init(isPrivate: false,
                                            blockPopups: blockPopups,
                                            isJSEnabled: isJsEnabled,
                                            canLoadPlugins: true)
        let opennet = Site("https://opennet.ru", "OpenNet", settings)
        let yahooFinance = Site("https://finance.yahoo.com", "Yahoo Finance", settings)
        let github = Site("https://github.com", "GitHub", settings)
        array = [opennet, yahooFinance, github]
        return array.compactMap {$0}
    }()
    
    private init() {
        selected = UIDevice.current.userInterfaceIdiom == .pad
    }
}

extension DefaultTabProvider: TabsStates {
    var addPosition: AddedTabPosition {
        FeatureManager.tabAddPositionValue()
    }
    
    var contentState: Tab.ContentType {
        FeatureManager.tabDefaultContentValue().contentType
    }
    
    var addSpeed: TabAddSpeed { .after(.milliseconds(300)) }
    
    var defaultSelectedTabId: UUID { .notPossibleId }
}

private extension UUID {
    static let notPossibleId: UUID = .init(uuid: (0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1))
}
