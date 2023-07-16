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
import CottonBase
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

@MainActor
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
    
    /// Depends on menu style and initial values of feaure flags
    init(_ menuStyle: BrowserMenuStyle,
         _ isDohEnabled: Bool,
         _ isJavaScriptEnabled: Bool,
         _ nativeAppRedirectEnabled: Bool) {
        style = menuStyle
        switch menuStyle {
        case .withSiteMenu(_, let settings):
            isTabJSEnabled = settings.isJSEnabled
        case .onlyGlobalMenu:
            isTabJSEnabled = true
        }
        self.isDohEnabled = isDohEnabled
        self.isJavaScriptEnabled = isJavaScriptEnabled
        self.nativeAppRedirectEnabled = nativeAppRedirectEnabled
        
        // for some reason below observers gets triggered
        // right away in init
        dohChangesCancellable = $isDohEnabled
            .dropFirst()
            .sink { value in
                Task {
                    await FeatureManager.shared.setFeature(.dnsOverHTTPSAvailable, value: value)
                }
            }
        jsEnabledOptionCancellable = $isJavaScriptEnabled
            .dropFirst()
            .sink { value in
                Task {
                    await FeatureManager.shared.setFeature(.javaScriptEnabled, value: value)
                }
            }
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
            .sink { value in
                Task {
                    await FeatureManager.shared.setFeature(.nativeAppRedirect, value: value)
                }
            }
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
