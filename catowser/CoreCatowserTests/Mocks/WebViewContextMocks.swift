//
//  WebViewContextMocks.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 10/5/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import CoreCatowser
import JSPlugins
import CoreHttpKit
import FeaturesFlagsKit

final class MockedWebViewContext: WebViewContext {
    let pluginsProgram: any JSPluginsProgram
    private let enableDoH: Bool
    private let enableJS: Bool
    private let asyncApiType: AsyncApiType
    
    init(doh: Bool, js: Bool, asyncApiType: AsyncApiType) {
        pluginsProgram = MockedJSPluginsProgram()
        enableDoH = doh
        enableJS = js
        self.asyncApiType = asyncApiType
    }
    
    public func nativeApp(for host: CoreHttpKit.Host) -> String? {
        return nil
    }
    
    public func isJavaScriptEnabled() -> Bool {
        return enableJS
    }
    
    public func isDohEnabled() -> Bool {
        return enableDoH
    }
    
    public func appAsyncApiTypeValue() -> AsyncApiType {
        return asyncApiType
    }
    
    public func updateTabContent(_ site: Site) throws {
        // Do nothing
    }
}
