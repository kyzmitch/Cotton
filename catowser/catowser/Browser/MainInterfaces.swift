//
//  MainInterfaces.swift
//  catowser
//
//  Created by Andrei Ermoshin on 6/1/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

import UIKit
import JSPlugins
import CoreHttpKit
import CoreBrowser

protocol MainDelegate: AnyObject {
    var keyboardHeight: CGFloat? { get set }
    var toolbarHeight: CGFloat { get }
    var toolbarTopAnchor: NSLayoutYAxisAnchor { get }
    var popoverSourceView: UIView { get }

    func openSearchSuggestion(url: URL, suggestion: String)
    func openDomain(with url: URL)
}

protocol TagsRouterInterface: AnyObject {
    func openTagsFor(instagram nodes: [InstagramVideoNode])
    func openTagsFor(html tags: [HTMLVideoTag])
    func closeTags()
}
