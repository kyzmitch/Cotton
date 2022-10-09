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

final class MockedMinimumCombineWebViewContext: WebViewContext {
    let pluginsProgram: any JSPluginsProgram
    
    init() {
        pluginsProgram = MockedJSPluginsProgram()
    }
    
    public func nativeApp(for host: Host) -> String? {
        return nil
    }
    
    public func isJavaScriptEnabled() -> Bool {
        return false
    }
    
    public func isDohEnabled() -> Bool {
        return false
    }
    
    public func appAsyncApiTypeValue() -> AsyncApiType {
        return .combine
    }
    
    public func updateTabContent(_ site: Site) throws {
        // Do nothing
    }
}

final class MockedDOHcombineWebViewContext: WebViewContext {
    let pluginsProgram: any JSPluginsProgram
    
    init() {
        pluginsProgram = MockedJSPluginsProgram()
    }
    
    public func nativeApp(for host: Host) -> String? {
        return nil
    }
    
    public func isJavaScriptEnabled() -> Bool {
        return false
    }
    
    public func isDohEnabled() -> Bool {
        return true
    }
    
    public func appAsyncApiTypeValue() -> AsyncApiType {
        return .combine
    }
    
    public func updateTabContent(_ site: Site) throws {
        // Do nothing
    }
}

final class MockedJScombineWebViewContext: WebViewContext {
    let pluginsProgram: any JSPluginsProgram
    
    init() {
        pluginsProgram = MockedJSPluginsProgram()
    }
    
    public func nativeApp(for host: Host) -> String? {
        return nil
    }
    
    public func isJavaScriptEnabled() -> Bool {
        return true
    }
    
    public func isDohEnabled() -> Bool {
        return false
    }
    
    public func appAsyncApiTypeValue() -> AsyncApiType {
        return .combine
    }
    
    public func updateTabContent(_ site: Site) throws {
        // Do nothing
    }
}
