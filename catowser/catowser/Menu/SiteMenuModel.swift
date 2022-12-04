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
import CoreHttpKit
import CoreBrowser
import FeaturesFlagsKit

enum MenuModelStyle {
    case siteMenu(Host, Site.Settings)
    case onlyGlobalMenu
}

protocol SiteMenuPresenter: AnyObject {
    func update(jsEnabled: Bool)
}

protocol DeveloperMenuPresenter: AnyObject {
    func emulateLinkTags()
}

@available(iOS 13.0, *)
final class SiteMenuModel: ObservableObject {
    @Published var isDohEnabled: Bool = FeatureManager.boolValue(of: .dnsOverHTTPSAvailable)
    @Published var isJavaScriptEnabled: Bool
    @Published var tabAddPosition = FeatureManager.tabAddPositionValue()
    @Published var tabDefaultContent = FeatureManager.tabDefaultContentValue()
    @Published var asyncApiType: AsyncApiType = FeatureManager.appAsyncApiTypeValue()
    
    private var dohChangesCancellable: AnyCancellable?
    private var jsEnabledOptionCancellable: AnyCancellable?
    
    let host: Host?
    
    let siteSettings: Site.Settings?
    
    private weak var siteMenuPresenter: SiteMenuPresenter?
    weak var developerMenuPresenter: DeveloperMenuPresenter?
    
    var siteSectionTitle: String {
        // site section is only available for site menu
        return .localizedStringWithFormat(.siteSectionTtl, host?.rawString ?? "")
    }
    
    var currentTabAddValue: String {
        return FeatureManager.tabAddPositionValue().description
    }
    
    var currentTabDefaultContent: String {
        return FeatureManager.tabDefaultContentValue().description
    }
    
    var selectedAsyncApiStringValue: String {
        return FeatureManager.appAsyncApiTypeValue().description
    }
    
    var selectedWebAutoCompleteStringValue: String {
        return FeatureManager.webSearchAutoCompleteValue().description
    }
    
    let viewTitle: String = .menuTtl
    
    init(_ menuStyle: MenuModelStyle,
         _ siteDelegate: SiteMenuPresenter?) {
        switch menuStyle {
        case .siteMenu(let host, let settings):
            self.host = host
            self.siteSettings = settings
            isJavaScriptEnabled = settings.isJSEnabled
        case .onlyGlobalMenu:
            host = nil
            siteSettings = nil
            // following properties can be removed later for only global kind of menues
            isJavaScriptEnabled = FeatureManager.boolValue(of: .javaScriptEnabled)
        }
        siteMenuPresenter = siteDelegate
        // for some reason below observers gets triggered
        // right away in init
        dohChangesCancellable = $isDohEnabled
            .dropFirst()
            .sink { FeatureManager.setFeature(.dnsOverHTTPSAvailable, value: $0) }
        jsEnabledOptionCancellable = $isJavaScriptEnabled
            .dropFirst()
            .sink(receiveValue: { [weak self] (jsEnabledValue) in
                self?.siteMenuPresenter?.update(jsEnabled: jsEnabledValue)
        })
    }
    
    deinit {
        dohChangesCancellable?.cancel()
        jsEnabledOptionCancellable?.cancel()
    }
    
    // MARK: - dev/debug menu handlers
    
    func emulateLinkTags() {
        developerMenuPresenter?.emulateLinkTags()
    }
}

private extension String {
    static let siteSectionTtl = NSLocalizedString("ttl_site_menu", comment: "Menu for tab")
    static let menuTtl = NSLocalizedString("ttl_common_menu", comment: "")
}
