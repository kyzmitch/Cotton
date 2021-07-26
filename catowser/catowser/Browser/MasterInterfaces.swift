//
//  MasterInterfaces.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/1/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import UIKit
import JSPlugins
import HttpKit
import CoreBrowser

protocol MasterDelegate: AnyObject {
    var keyboardHeight: CGFloat? { get set }
    var toolbarHeight: CGFloat { get }
    var toolbarTopAnchor: NSLayoutYAxisAnchor { get }
    var popoverSourceView: UIView { get }

    func openSearchSuggestion(url: URL, suggestion: String)
    func openDomain(with url: URL)
}

protocol TagsRouterInterface: AnyObject {
    func openTagsFor(instagram nodes: [InstagramVideoNode])
    func openTagsFor(t4 video: T4Video)
    func openTagsFor(html tags: [HTMLVideoTag])
    func closeTags()
}

protocol SiteLifetimeInterface {
    func showProgress(_ show: Bool)
    
    func openTabMenu(from sourceView: UIView,
                     and sourceRect: CGRect,
                     for host: HttpKit.Host,
                     siteSettings: Site.Settings)
}
