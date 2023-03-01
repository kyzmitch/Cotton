//
//  WebViewContextImpl.swift
//  catowser
//
//  Created by Andrei Ermoshin on 10/3/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import Foundation
import CottonCoreBaseKit
import CoreCatowser
import CoreBrowser
import JSPlugins
import FeaturesFlagsKit

private var logTabUpdate = false

public final class WebViewContextImpl: WebViewContext {
    public let pluginsProgram: any JSPluginsProgram
    
    init(_ program: any JSPluginsProgram) {
        pluginsProgram = program
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
    
    public func allowNativeAppRedirects() -> Bool {
        return FeatureManager.boolValue(of: .nativeAppRedirect)
    }
    
    public func appAsyncApiTypeValue() -> AsyncApiType {
        return FeatureManager.appAsyncApiTypeValue()
    }
    
    public func updateTabContent(_ site: Site) throws {
        let content: Tab.ContentType = .site(site)
        if logTabUpdate {
            print("Web VM tab update: \(content.debugDescription)")
        }
        try TabsListManager.shared.replaceSelected(content)
    }
}
