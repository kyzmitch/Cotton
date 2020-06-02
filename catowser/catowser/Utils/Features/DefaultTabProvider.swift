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
        let newsruCom = Site(urlString: "https://m.newsru.com",
                             customTitle: "Newsru.com",
                             settings: settings)
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
enum TabContentDefaultState: Int, CaseIterable, CustomStringConvertible {
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
    
    public var description: String {
        let key: String
        
        switch self {
        case .blank:
            key = "txt_tab_content_blank"
        case .homepage:
            key = "txt_tab_content_homepage"
        case .favorites:
            key = "txt_tab_content_favorites"
        case .topSites:
            key = "txt_tab_content_top_sites"
        }
        return NSLocalizedString(key, comment: "")
    }
}
