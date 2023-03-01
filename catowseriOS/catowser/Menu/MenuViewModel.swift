//
//  MenuViewModel.swift
//  catowser
//
//  Created by Andrei Ermoshin on 5/26/20.
//  Copyright © 2020 andreiermoshin. All rights reserved.
//

#if canImport(Combine)
import Combine
#endif
import CottonCoreBaseKit
import CoreBrowser
import FeaturesFlagsKit

enum BrowserMenuStyle {
    case withSiteMenu(Host, Site.Settings)
    case onlyGlobalMenu
}

protocol DeveloperMenuPresenter: AnyObject {
    func emulateLinkTags()
    /// This method is not for dev only and should be available in any build types
    func host(_ host: Host, willUpdateJsState enabled: Bool)
}

@available(iOS 13.0, *)
final class MenuViewModel: ObservableObject {
    // MARK: - global settings
    
    @Published var isDohEnabled: Bool
    @Published var isJavaScriptEnabled: Bool
    @Published var nativeAppRedirectEnabled: Bool
    
    // MARK: - specific tab settings
    
    @Published var isTabJSEnabled: Bool
    
    // MARK: - disposables
    
    private var dohChangesCancellable: AnyCancellable?
    private var jsEnabledOptionCancellable: AnyCancellable?
    private var tabjsEnabledCancellable: AnyCancellable?
    private var nativeAppRedirectCancellable: AnyCancellable?
    
    // MARK: - state
    
    let style: BrowserMenuStyle
    private var host: Host? {
        if case let .withSiteMenu(host, _) = style {
            return host
        }
        return nil
    }
    private var siteSettings: Site.Settings? {
        if case let .withSiteMenu(_, settings) = style {
            return settings
        }
        return nil
    }
    
    // MARK: - delegates
    
    weak var developerMenuPresenter: DeveloperMenuPresenter?
    
    // MARK: - text properties
    
    var siteSectionTitle: String {
        // site section is only available for site menu
        return .localizedStringWithFormat(.siteSectionTtl, host?.rawString ?? "")
    }
    
    let viewTitle: String = .menuTtl
    
    // MARK: - init
    
    init(_ menuStyle: BrowserMenuStyle) {
        style = menuStyle
        switch menuStyle {
        case .withSiteMenu(_, let settings):
            isTabJSEnabled = settings.isJSEnabled
        case .onlyGlobalMenu:
            isTabJSEnabled = true
        }
        isDohEnabled = FeatureManager.boolValue(of: .dnsOverHTTPSAvailable)
        isJavaScriptEnabled = FeatureManager.boolValue(of: .javaScriptEnabled)
        nativeAppRedirectEnabled = FeatureManager.boolValue(of: .nativeAppRedirect)
        
        // for some reason below observers gets triggered
        // right away in init
        dohChangesCancellable = $isDohEnabled
            .dropFirst()
            .sink { FeatureManager.setFeature(.dnsOverHTTPSAvailable, value: $0) }
        jsEnabledOptionCancellable = $isJavaScriptEnabled
            .dropFirst()
            .sink { FeatureManager.setFeature(.javaScriptEnabled, value: $0) }
        tabjsEnabledCancellable = $isTabJSEnabled
            .sink(receiveValue: { [weak self] newValue in
                guard let self = self else {
                    return
                }
                guard case let .withSiteMenu(host, _) = self.style  else {
                    return
                }
                self.developerMenuPresenter?.host(host, willUpdateJsState: newValue)
            })
        nativeAppRedirectCancellable = $nativeAppRedirectEnabled
            .dropFirst()
            .sink { FeatureManager.setFeature(.nativeAppRedirect, value: $0) }
    }
    
    deinit {
        dohChangesCancellable?.cancel()
        jsEnabledOptionCancellable?.cancel()
        tabjsEnabledCancellable?.cancel()
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
