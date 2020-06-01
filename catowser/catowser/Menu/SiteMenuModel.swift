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

protocol SiteSettingsInterface: class {
    func update(jsEnabled: Bool)
}

@available(iOS 13.0, *)
final class SiteMenuModel: ObservableObject {
    @Published var isDohEnabled: Bool = FeatureManager.boolValue(of: .dnsOverHTTPSAvailable)
    @Published var isJavaScriptEnabled: Bool = true
    @Published var tabAddPosition = FeatureManager.tabAddPositionValue()
    @Published var tabDefaultContent = FeatureManager.tabDefaultContentValue()
    
    private var dohChangesCancellable: AnyCancellable?
    private var jsEnabledOptionCancellable: AnyCancellable?
    
    typealias DismissClosure = () -> Void
    
    let dismissAction: DismissClosure
    
    let host: HttpKit.Host
    
    weak var siteSettingsDelegate: SiteSettingsInterface?
    
    var siteSectionTitle: String {
        return .localizedStringWithFormat(.siteSectionTtl, host.rawValue)
    }
    
    var currentTabAddValue: String {
        return FeatureManager.tabAddPositionValue().description
    }
    
    var currentTabDefaultContent: String {
        return FeatureManager.tabDefaultContentValue().description
    }
    
    let viewTitle: String = .menuTtl
    
    init(host: HttpKit.Host,
         siteDelegate: SiteSettingsInterface?,
         dismiss: @escaping DismissClosure) {
        self.host = host
        siteSettingsDelegate = siteDelegate
        dismissAction = dismiss
        dohChangesCancellable = $isDohEnabled.sink { FeatureManager.setFeature(.dnsOverHTTPSAvailable, value: $0) }
        jsEnabledOptionCancellable = $isJavaScriptEnabled.sink(receiveValue: { [weak self] (jsEnabledValue) in
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
