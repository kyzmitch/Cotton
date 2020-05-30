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

typealias DismissClosure = () -> Void

@available(iOS 13.0, *)
final class SiteMenuModel: ObservableObject {
    @Published var isDohEnabled = FeatureManager.boolValue(of: .dnsOverHTTPSAvailable)
    @Published var tabAddPosition = FeatureManager.tabAddPositionValue()
    @Published var tabDefaultContent = FeatureManager.tabDefaultContentValue()
    
    private var dohChangesCancellable: AnyCancellable?
    
    let dismissAction: DismissClosure
    
    let host: HttpKit.Host
    
    init(host: HttpKit.Host, dismiss: @escaping DismissClosure) {
        self.host = host
        dismissAction = dismiss
        dohChangesCancellable = $isDohEnabled.sink { FeatureManager.setFeature(.dnsOverHTTPSAvailable, value: $0)}
    }
    
    deinit {
        dohChangesCancellable?.cancel()
    }
}
