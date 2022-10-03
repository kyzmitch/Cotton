//
//  WebViewContextImpl.swift
//  catowser
//
//  Created by Andrei Ermoshin on 10/3/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import CoreHttpKit
import CoreCatowser
import CoreBrowser
import JSPlugins
import FeaturesFlagsKit

public final class WebViewContextImpl: WebViewContext {
    /// Plugins are optional because there is possibility that js files are not present or plugins delegates are not set
    public let pluginsProgram: JSPluginsProgram
    
    init(_ pluginsSource: JSPluginsSource) {
        pluginsProgram = pluginsSource.pluginsProgram
    }
    
    public func nativeApp(for host: Host) -> String? {
        guard let checker = try? DomainNativeAppChecker(host: host) else {
            return nil
        }
        return checker.correspondingDomain
    }
    
    public func isJavaScriptEnabled() -> Bool {
        return FeatureManager.boolValue(of: .javaScriptEnabled)
    }
    
    public func isDohEnabled() -> Bool {
        return FeatureManager.boolValue(of: .dnsOverHTTPSAvailable)
    }
    
    public func appAsyncApiTypeValue() -> AsyncApiType {
        return FeatureManager.appAsyncApiTypeValue()
    }
    
    public func updateTabContent(_ site: Site) throws {
        try TabsListManager.shared.replaceSelected(tabContent: .site(site))
    }
}
