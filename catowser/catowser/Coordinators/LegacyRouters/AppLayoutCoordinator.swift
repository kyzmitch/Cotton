//
//  AppLayoutCoordinator.swift
//  catowser
//
//  Created by Andrei Ermoshin on 03/04/2019.
//  Copyright © 2019 andreiermoshin. All rights reserved.
//

import UIKit
import CoreBrowser
import JSPlugins
import CoreHttpKit
import BrowserNetworking
import FeaturesFlagsKit
#if canImport(SwiftUI)
import SwiftUI
#endif

protocol MediaLinksPresenter: AnyObject {
    func didReceiveMediaLinks()
}

/// Should contain copies for references to all needed constraints and view controllers.
/// NSObject subclass to support system delegate protocol.
final class AppLayoutCoordinator: NSObject {
    
    private weak var mediaLinksPresenter: MediaLinksPresenter?



    

    var hiddenFilesGreedConstraint: NSLayoutConstraint?

    var showedFilesGreedConstraint: NSLayoutConstraint?

    var filesGreedHeightConstraint: NSLayoutConstraint?

    var underLinksViewHeightConstraint: NSLayoutConstraint?

    private var isLinkTagsShowed: Bool = false

    let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad

    private(set) weak var presenter: AnyViewController!
    
    private weak var menuDelegate: GlobalMenuDelegate!

    init(_ presenter: AnyViewController, _ menuDelegate: GlobalMenuDelegate) {
        self.presenter = presenter
        self.menuDelegate = menuDelegate
    }
    
    // MARK: - originally private methods
    
    
}
