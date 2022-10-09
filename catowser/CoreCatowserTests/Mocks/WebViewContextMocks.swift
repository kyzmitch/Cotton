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

final class MockedCombineWebViewContext: WebViewContext {
    let pluginsProgram: any JSPluginsProgram
    private let enableDoH: Bool
    private let enableJS: Bool
    
    init(doh: Bool, js: Bool) {
        pluginsProgram = MockedJSPluginsProgram()
        enableDoH = doh
        enableJS = js
    }
    
    public func nativeApp(for host: Host) -> String? {
        return nil
    }
    
    public func isJavaScriptEnabled() -> Bool {
        return enableJS
    }
    
    public func isDohEnabled() -> Bool {
        return enableDoH
    }
    
    public func appAsyncApiTypeValue() -> AsyncApiType {
        return .combine
    }
    
    public func updateTabContent(_ site: Site) throws {
        // Do nothing
    }
}
