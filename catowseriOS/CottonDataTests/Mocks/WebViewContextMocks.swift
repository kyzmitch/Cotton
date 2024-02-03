//
//  WebViewContextMocks.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 10/5/22.
//  Copyright © 2022 Cotton/Catowser Andrei Ermoshin. All rights reserved.
//

import CottonData
import CottonPlugins
import CottonBase
import FeaturesFlagsKit

final class MockedWebViewContext: WebViewContext {
    let pluginsProgram: any JSPluginsProgram
    private var enableDoH: Bool
    private let enableJS: Bool
    private let nativeAppRedirect: Bool
    private let asyncApiType: AsyncApiType
    private let appName: String?
    
    init(doh: Bool,
         js: Bool,
         nativeAppRedirect: Bool,
         asyncApiType: AsyncApiType,
         appName: String? = nil) {
        pluginsProgram = MockedJSPluginsProgram()
        enableDoH = doh
        enableJS = js
        self.nativeAppRedirect = nativeAppRedirect
        self.asyncApiType = asyncApiType
        self.appName = appName
    }
    
    /// Method needed to be able to test change of DoH
    /// because View model doesn't save DoH state
    /// and uses Context for that
    func setDNSoverHTTPs(_ enabled: Bool) {
        enableDoH = enabled
    }
    
    public func nativeApp(for host: CottonBase.Host) -> String? {
        guard let value = appName else {
            return nil
        }
        return host.isSimilar(name: value) ? appName : nil
    }
    
    public func isJavaScriptEnabled() async -> Bool {
        return enableJS
    }
    
    public func isDohEnabled() async -> Bool {
        return enableDoH
    }
    
    public func allowNativeAppRedirects() async -> Bool {
        return nativeAppRedirect
    }
    
    public func appAsyncApiTypeValue() -> AsyncApiType {
        return asyncApiType
    }
    
    public func updateTabContent(_ site: Site) async throws {
        // Do nothing
    }
}
