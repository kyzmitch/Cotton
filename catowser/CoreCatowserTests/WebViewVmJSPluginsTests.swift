//
//  WebViewVmJSPluginsTests.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 10/8/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import XCTest
@testable import CoreCatowser
import HttpKit
import CoreHttpKit
import WebKit

final class WebViewVmJSPluginsTests: WebViewVMFixture {
    
    override func setUpWithError() throws {
        exampleIpAddress = "100.0.12.7"
        try super.setUpWithError()
        webViewContext = .init(doh: false, js: true)
        settings = .init(isPrivate: false,
                         blockPopups: true,
                         isJSEnabled: true,
                         canLoadPlugins: false)
    }

    func testInit() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, webViewContext)
        XCTAssertEqual(vm.host.content, Host.Content.domainname)
        XCTAssertEqual(vm.host.rawString, exampleDomainName.rawString)
        XCTAssertEqual(vm.urlInfo, exampleURLInfo)
        XCTAssertEqual(vm.settings, settings)
        XCTAssertEqual(vm.currentURL, urlV1)
        XCTAssertNotEqual(vm.currentURL, wrongUrlV1)
        XCTAssertNotEqual(vm.currentURL, wrongUrlV2)
        XCTAssertNotEqual(vm.currentURL, wrongUrlV3)
        XCTAssertNil(vm.nativeAppDomainNameString)
        XCTAssertEqual(vm.combineWebPageState.value, .recreateView(false))
        XCTAssertEqual(vm.state, .initialized(exampleSite))
    }
    
    func testLoad() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, webViewContext)
        vm.load()
        // swiftlint:disable:next force_unwrapping
        let urlRequestV1 = URLRequest(url: urlV1!)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV1))
        // swiftlint:disable:next force_unwrapping
        let urlInfoV1: URLInfo = .init(urlV1!)!
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlInfoV1))
        // swiftlint:disable:next force_unwrapping
        let navActionV1 = MockedNavAction(urlV1!, .other)
        vm.decidePolicy(navActionV1) { policy in
            XCTAssertEqual(policy, .allow)
        }
        
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV1))
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV1))
    }
    
    func testChangeJSstate() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, webViewContext)
        vm.load()
        // swiftlint:disable:next force_unwrapping
        let urlRequestV1 = URLRequest(url: urlV1!)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV1))
        // swiftlint:disable:next force_unwrapping
        let urlInfoV1: URLInfo = .init(urlV1!)!
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlInfoV1))
        // swiftlint:disable:next force_unwrapping
        let navActionV1 = MockedNavAction(urlV1!, .other)
        vm.decidePolicy(navActionV1) { policy in
            XCTAssertEqual(policy, .allow)
        }
        
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV1))
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV1))
        
        // JS was already enabled
        
        vm.setJavaScript(jsSubject, true)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV1))
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV1))
        
        // User disables JS
        
        vm.setJavaScript(jsSubject, false)
        let expectedSettingsV1: Site.Settings = settings.withChanged(javaScriptEnabled: false)
        let expectedStateV1: WebViewModelState = .updatingJS(expectedSettingsV1, jsSubject, urlInfoV1)
        XCTAssertEqual(vm.state, expectedStateV1)
        
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV1))
        XCTAssertEqual(vm.state, .viewing(expectedSettingsV1, urlInfoV1))
        
        // User enables JS back
        
        vm.setJavaScript(jsSubject, true)
        let expectedSettingsV2: Site.Settings = expectedSettingsV1.withChanged(javaScriptEnabled: true)
        let expectedStateV2: WebViewModelState = .updatingJS(expectedSettingsV2, jsSubject, urlInfoV1)
        XCTAssertEqual(vm.state, expectedStateV2)
        
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV1))
        XCTAssertEqual(vm.state, .viewing(expectedSettingsV2, urlInfoV1))
    }
}
