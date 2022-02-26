//
//  DefaultTabProvider.swift
//  catowser
//
//  Created by Andrei Ermoshin on 01/02/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser

final class DefaultTabProvider {
    static let shared = DefaultTabProvider()
    
    let selected: Bool
    
    let blockPopups: Bool = false

    lazy var topSites: [Site] = {
        let array: [Site?]
        let isJsEnabled = FeatureManager.boolValue(of: .javaScriptEnabled)
        let settings: Site.Settings = .init(popupsBlock: blockPopups,
                                            javaScriptEnabled: isJsEnabled)
        let instagramImage = UIImage(named: "instagram")
        let ig = Site(urlString: "https://www.instagram.com",
                      customTitle: "Instagram",
                      image: instagramImage,
                      settings: settings)
        let youtubeImage = UIImage(named: "youtube")
        let tube = Site(urlString: "https://youtube.com",
                        customTitle: "Youtube",
                        image: youtubeImage,
                        settings: settings)
        let opennet = Site(urlString: "https://opennet.ru",
                           customTitle: "OpenNet",
                           settings: settings)
        let meduza = Site(urlString: "https://meduza.io",
                          customTitle: "Meduza",
                          settings: settings)
        let yahooFinance = Site(urlString: "https://finance.yahoo.com",
                                customTitle: "Yahoo Finance",
                                settings: settings)
        let github = Site(urlString: "https://github.com",
                          customTitle: "GitHub",
                          settings: settings)
        array = [ig, tube, opennet, meduza, yahooFinance, github]
        return array.compactMap {$0}
    }()
    
    private init() {
        selected = UIDevice.current.userInterfaceIdiom == .pad
    }
}

extension DefaultTabProvider: TabsPositioning {
    var addPosition: AddedTabPosition {
        return FeatureManager.tabAddPositionValue()
    }
    
    var contentState: Tab.ContentType { .topSites }
    
    var addSpeed: TabAddSpeed { .after(.milliseconds(300)) }
    
    var defaultSelectedTabId: UUID { .notPossibleId }
}

private extension UUID {
    static let notPossibleId: UUID = .init(uuid: (0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1))
}
