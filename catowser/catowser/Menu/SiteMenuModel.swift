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

@available(iOS 13.0, *)
final class SiteMenuModel: ObservableObject {
    @Published var isDohEnabled = FeatureManager.boolValue(of: .dnsOverHTTPSAvailable)
    @Published var tabAddPosition = FeatureManager.tabAddPositionValue()
    @Published var tabDefaultContent = FeatureManager.tabDefaultContentValue()
    
    private var dohChangesCancellable: AnyCancellable?
    
    typealias DismissClosure = () -> Void
    
    let dismissAction: DismissClosure
    
    let host: HttpKit.Host
    
    var siteSectionTitle: String {
        return .localizedStringWithFormat(.siteSectionTtl, host.rawValue)
    }
    
    var currentTabAddValue: String {
        return FeatureManager.tabAddPositionValue().description
    }
    
    let viewTitle: String = .menuTtl
    
    init(host: HttpKit.Host, dismiss: @escaping DismissClosure) {
        self.host = host
        dismissAction = dismiss
        dohChangesCancellable = $isDohEnabled.sink { FeatureManager.setFeature(.dnsOverHTTPSAvailable, value: $0)}
    }
    
    deinit {
        dohChangesCancellable?.cancel()
    }
}

private extension String {
    static let siteSectionTtl = NSLocalizedString("ttl_site_menu", comment: "Menu for tab")
    static let menuTtl = NSLocalizedString("ttl_common_menu", comment: "")
}
