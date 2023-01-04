//
//  WebView.swift
//  catowser
//
//  Created by Andrei Ermoshin on 12/19/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import SwiftUI
import CoreHttpKit

/// web view specific to SwiftUI
struct WebView: View {
    @ObservedObject var model: WebViewModelV2
    private let site: Site
    
    init(_ model: WebViewModelV2,
         _ site: Site) {
        self.model = model
        self.site = site
    }
    
    var body: some View {
        WebViewLegacyView(model: model, site: site)
    }
}

/// SwiftUI wrapper around UIKit web view view controller
private struct WebViewLegacyView: UIViewControllerRepresentable {
    @ObservedObject private var model: WebViewModelV2
    private let site: Site
    typealias UIViewControllerType = UIViewController
    /// Usual coordinator can't really be used for SwiftUI navigation
    /// but for the legacy view it has to be passed
    private let dummyArgument: WebContentCoordinator? = nil
    /// Convinience property to get a manager
    private var manager: WebViewsReuseManager {
        ViewsEnvironment.shared.reuseManager
    }
    
    init(model: WebViewModelV2, site: Site) {
        self.model = model
        self.site = site
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        // Can't save web view interface here because it is immutable type.
        // Could be possible to fetch it from `WebViewsReuseManager` if it is
        // configured to use web views cache.
        let vc: (AnyViewController & WebViewNavigatable)? = try? manager.controllerFor(site,
                                                                                       model.jsPluginsBuilder,
                                                                                       model.siteNavigation,
                                                                                       dummyArgument)
        // swiftlint:disable:next force_unwrapping
        return vc!.viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        guard let navigatable = uiViewController as? WebViewNavigatable else {
            return
        }
        print("Only for debug purposes to understand how it works")
    }
    
    static func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: ()) {
        guard let navigatable = uiViewController as? WebViewNavigatable else {
            return
        }
        print("Only for debug purposes to understand how it works")
    }
}