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

@available(iOS 13.0, *)
final class SiteMenuModel: ObservableObject {
    @Published var isDohEnabled = FeatureManager.boolValue(of: .dnsOverHTTPSAvailable)
    
    private var dohChangesCancellable: AnyCancellable?
    
    typealias DismissClosure = () -> Void
    
    let dismissAction: DismissClosure
    
    init(dismiss: @escaping DismissClosure) {
        dismissAction = dismiss
        dohChangesCancellable = $isDohEnabled.sink { FeatureManager.setFeature(.dnsOverHTTPSAvailable, value: $0)}
    }
    
    deinit {
        dohChangesCancellable?.cancel()
    }
}
