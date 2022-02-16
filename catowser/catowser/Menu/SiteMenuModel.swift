//
//  SiteMenuModel.swift
//  catowser
//
//  Created by Andrei Ermoshin on 5/26/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

#if canImport(Combine)
import Combine
#endif
import HttpKit
import CoreBrowser

enum MenuModelStyle {
    case siteMenu(host: HttpKit.Host, siteSettings: Site.Settings)
    case onlyGlobalMenu
}

protocol SiteSettingsInterface: AnyObject {
    func update(jsEnabled: Bool)
}

typealias DismissClosure = () -> Void

@available(iOS 13.0, *)
final class SiteMenuModel: ObservableObject {
    @Published var isDohEnabled: Bool = FeatureManager.boolValue(of: .dnsOverHTTPSAvailable)
    @Published var isJavaScriptEnabled: Bool
    @Published var tabAddPosition = FeatureManager.tabAddPositionValue()
    @Published var tabDefaultContent = FeatureManager.tabDefaultContentValue()
    @Published var asyncApiType: AsyncApiType = FeatureManager.appDefaultAsyncApiTypeValue()
    
    private var dohChangesCancellable: AnyCancellable?
    private var jsEnabledOptionCancellable: AnyCancellable?
    
    let dismissAction: DismissClosure
    
    let host: HttpKit.Host?
    
    let siteSettings: Site.Settings?
    
    weak var siteSettingsDelegate: SiteSettingsInterface?
    
    var siteSectionTitle: String {
        // site section is only available for site menu
        return .localizedStringWithFormat(.siteSectionTtl, host?.rawValue ?? "")
    }
    
    var currentTabAddValue: String {
        return FeatureManager.tabAddPositionValue().description
    }
    
    var currentTabDefaultContent: String {
        return FeatureManager.tabDefaultContentValue().description
    }
    
    var selectedAsyncApiStringValue: String {
        return FeatureManager.appDefaultAsyncApiTypeValue().description
    }
    
    let viewTitle: String = .menuTtl
    
    init(menuStyle: MenuModelStyle,
         siteDelegate: SiteSettingsInterface?,
         dismiss: @escaping DismissClosure) {
        switch menuStyle {
        case .siteMenu(host: let host, siteSettings: let settings):
            self.host = host
            self.siteSettings = settings
            isJavaScriptEnabled = settings.isJsEnabled
        case .onlyGlobalMenu:
            host = nil
            siteSettings = nil
            // following properties can be removed later for only global kind of menues
            isJavaScriptEnabled = FeatureManager.boolValue(of: .javaScriptEnabled)
        }
        siteSettingsDelegate = siteDelegate
        dismissAction = dismiss
        // for some reason below observers gets triggered
        // right away in init
        dohChangesCancellable = $isDohEnabled
            .dropFirst()
            .sink { FeatureManager.setFeature(.dnsOverHTTPSAvailable, value: $0) }
        jsEnabledOptionCancellable = $isJavaScriptEnabled
            .dropFirst()
            .sink(receiveValue: { [weak self] (jsEnabledValue) in
                self?.siteSettingsDelegate?.update(jsEnabled: jsEnabledValue)
        })
    }
    
    deinit {
        dohChangesCancellable?.cancel()
        jsEnabledOptionCancellable?.cancel()
    }
}

private extension String {
    static let siteSectionTtl = NSLocalizedString("ttl_site_menu", comment: "Menu for tab")
    static let menuTtl = NSLocalizedString("ttl_common_menu", comment: "")
}
