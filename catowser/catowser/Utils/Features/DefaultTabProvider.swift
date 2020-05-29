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
        let instagramImage = UIImage(named: "instagram")
        let ig = Site(urlString: "https://www.instagram.com",
                      customTitle: "Instagram",
                      image: instagramImage,
                      blockPopups: blockPopups)
        let youtubeImage = UIImage(named: "youtube")
        let tube = Site(urlString: "https://youtube.com",
                        customTitle: "Youtube",
                        image: youtubeImage,
                        blockPopups: blockPopups)
        let opennet = Site(urlString: "https://opennet.ru",
                           customTitle: "OpenNet",
                           blockPopups: blockPopups)
        let meduza = Site(urlString: "https://meduza.io",
                          customTitle: "Meduza",
                          blockPopups: blockPopups)
        let newsruCom = Site(urlString: "https://m.newsru.com",
                             customTitle: "Newsru.com",
                             blockPopups: blockPopups)
        array = [ig, tube, opennet, meduza, newsruCom]
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
}

/// Twin type for `Tab.ContentType` to have `rawValue`
/// and use it for settings.
enum TabContentDefaultState: Int {
    case blank
    case homepage
    case favorites
    case topSites
    
    var contentType: Tab.ContentType {
        switch self {
        case .blank:
            return .blank
        case .homepage:
            return .homepage
        case .favorites:
            return .favorites
        case .topSites:
            return .topSites
        }
    }
}
