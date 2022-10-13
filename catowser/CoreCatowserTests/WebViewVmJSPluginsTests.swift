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

final class WebViewVmJSPluginsTests: XCTestCase {

    let goodServerMock: MockedGoodDnsServer = .init()
    let goodJsonEncodingMock: MockedGoodJSONEncoding = .init()
    // swiftlint:disable:next force_unwrapping
    lazy var goodReachabilityMock: MockedReachabilityAdaptee = .init(server: goodServerMock)!
    lazy var goodDnsClient: RestClient<MockedGoodDnsServer, MockedReachabilityAdaptee> = {
        .init(server: goodServerMock, jsonEncoder: goodJsonEncodingMock, reachability: goodReachabilityMock)
    }()
    let rxSubscriber: MockedDNSContext.HttpKitRxSubscriber = .init()
    let subscriber: MockedDNSContext.HttpKitSubscriber = .init()
    lazy var goodDnsContext: MockedDNSContext = {
        .init(goodDnsClient, rxSubscriber, subscriber)
    }()
    let exampleIpAddress = "100.0.12.7"
    lazy var goodDnsStrategy: MockedDNSStrategy = {
        .init(goodDnsContext, exampleIpAddress)
    }()
    let jsWebViewContext: MockedCombineWebViewContext = .init(doh: false, js: true)
    let jsDoHWebViewContext: MockedCombineWebViewContext = .init(doh: true, js: true)
    
    let settings: Site.Settings = .init(isPrivate: false,
                                        blockPopups: true,
                                        isJSEnabled: true,
                                        canLoadPlugins: true)
    
    // swiftlint:disable:next force_try
    let exampleDomainName: DomainName = try! .init(input: "www.example.com")
    lazy var exampleURLInfo: URLInfo = .init(scheme: .https,
                                             path: "foo/bar",
                                             query: nil,
                                             domainName: exampleDomainName,
                                             ipAddress: nil)
    lazy var exampleSite: Site = .init(urlInfo: exampleURLInfo,
                                       settings: settings,
                                       faviconData: nil,
                                       searchSuggestion: nil,
                                       userSpecifiedTitle: nil)
    
    let urlV1 = URL(string: "https://www.example.com/foo/bar")
    let urlV2 = URL(string: "https://www.example.com/foo/bar_2")
    let urlV3 = URL(string: "https://www.known.com/bar")
    let wrongUrlV1 = URL(string: "http://www.example.com/foo/bar")
    let wrongUrlV2 = URL(string: "https://www.example.com/foo")
    let wrongUrlV3 = URL(string: "https://www.google.com/foo/bar")
    
    let jsSubject: MockedWebViewWithError = .init()

    func testInit() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, jsWebViewContext)
        XCTAssertEqual(vm.host.content, Host.Content.domainname)
        XCTAssertEqual(vm.host.rawString, exampleDomainName.rawString)
        XCTAssertEqual(vm.urlInfo, exampleURLInfo)
        XCTAssertEqual(vm.settings, settings)
        XCTAssertEqual(vm.currentURL, urlV1)
        XCTAssertNotEqual(vm.currentURL, wrongUrlV1)
        XCTAssertNotEqual(vm.currentURL, wrongUrlV2)
        XCTAssertNotEqual(vm.currentURL, wrongUrlV3)
        XCTAssertNil(vm.nativeAppDomainNameString)
        XCTAssertEqual(vm.combineWebPageState.value, .idle)
        XCTAssertEqual(vm.state, .initialized(exampleSite))
    }
    
    func testLoad() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, jsWebViewContext)
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
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, jsWebViewContext)
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
    
    func testChangeJSstateWhenDNSoverHTTPSisEnabled() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, jsDoHWebViewContext)
        vm.load()
        XCTAssertEqual(vm.combineWebPageState.value, .idle)
        // swiftlint:disable:next force_unwrapping
        let urlInfoV1 = URLInfo(urlV1!)!
        let expectedStateV1: WebViewModelState = .resolvingDN(urlInfoV1, settings)
        XCTAssertEqual(vm.state, expectedStateV1)
        _ = XCTWaiter.wait(for: [expectation(description: "Wait for async domain name resolving")], timeout: 1.0)
        // swiftlint:disable:next force_unwrapping force_try
        let resolvedUrlV1 = try! urlV1!.updatedHost(with: exampleIpAddress)
        let urlRequestV1 = URLRequest(url: resolvedUrlV1)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV1))
        let urlInfoV11: URLInfo = urlInfoV1.withIPAddress(ipAddress: exampleIpAddress)
        let expectedStateV11: WebViewModelState = .updatingWebView(settings, urlInfoV11)
        XCTAssertEqual(vm.state, expectedStateV11)
        
        let navActionV1 = MockedNavAction(resolvedUrlV1, .other)
        vm.decidePolicy(navActionV1) { policy in
            XCTAssertEqual(policy, .allow)
        }
        vm.finishLoading(resolvedUrlV1, jsSubject)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV1))
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV11))
        
        // JS was already enabled
        
        vm.setJavaScript(jsSubject, true)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV1))
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV11))
        
        // User disables JS
        
        vm.setJavaScript(jsSubject, false)
        let expectedSettingsV2: Site.Settings = settings.withChanged(javaScriptEnabled: false)
        let expectedStateV2: WebViewModelState = .updatingJS(expectedSettingsV2, jsSubject, urlInfoV11)
        XCTAssertEqual(vm.state, expectedStateV2)
        
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV1))
        XCTAssertEqual(vm.state, .viewing(expectedSettingsV2, urlInfoV11))
        
        // User enables JS back
        
        vm.setJavaScript(jsSubject, true)
        let expectedSettingsV3: Site.Settings = expectedSettingsV2.withChanged(javaScriptEnabled: true)
        let expectedStateV3: WebViewModelState = .updatingJS(expectedSettingsV3, jsSubject, urlInfoV11)
        XCTAssertEqual(vm.state, expectedStateV3)
        
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV1))
        XCTAssertEqual(vm.state, .viewing(expectedSettingsV3, urlInfoV11))
    }
}
