//
//  WebViewVMCombineTests.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 10/3/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import XCTest
@testable import CoreCatowser
import HttpKit
import CoreHttpKit
import WebKit

final class WebViewVMCombineTests: XCTestCase {
    
    let goodServerMock: MockedGoodDnsServer = .init()
    let goodJsonEncodingMock: MockedGoodJSONEncoding = .init()
    // swiftlint:disable:next force_unwrapping
    lazy var goodReachabilityMock: MockedReachabilityAdaptee = .init(server: goodServerMock)!
    lazy var goodDnsClient: RestClient<MockedGoodDnsServer, MockedReachabilityAdaptee, MockedGoodJSONEncoding> = {
        .init(server: goodServerMock, jsonEncoder: goodJsonEncodingMock, reachability: goodReachabilityMock)
    }()
    let rxSubscriber: MockedDNSContext.HttpKitRxSubscriber = .init()
    let subscriber: MockedDNSContext.HttpKitSubscriber = .init()
    lazy var goodDnsContext: MockedDNSContext = {
        .init(goodDnsClient, rxSubscriber, subscriber)
    }()
    lazy var goodDnsStrategy: MockedDNSStrategy = {
        .init(goodDnsContext)
    }()
    let minimumWebViewContext: MockedCombineWebViewContext = .init(doh: false, js: false)
    
    let settings: Site.Settings = .init(isPrivate: false,
                                        blockPopups: true,
                                        isJSEnabled: false,
                                        canLoadPlugins: false)
    
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
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, minimumWebViewContext)
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
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, minimumWebViewContext)
        vm.load()
        // swiftlint:disable:next force_unwrapping
        let urlInfoV1: URLInfo = .init(urlV1!)!
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlInfoV1.urlRequest))
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlInfoV1))
        vm.load()
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlInfoV1.urlRequest))
        let errMsg1 = "State should stay the same when wrong action is getting called"
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlInfoV1), errMsg1)
        // swiftlint:disable:next force_unwrapping
        let navActionV1 = MockedNavAction(urlV1!, .other)
        vm.decidePolicy(navActionV1) { policy in
            XCTAssertEqual(policy, .allow)
        }
        
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlInfoV1.urlRequest))
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV1))
    }
    
    func testLinkActivation() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, minimumWebViewContext)
        vm.load()
        // swiftlint:disable:next force_unwrapping
        let urlInfoV1: URLInfo = .init(urlV1!)!
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlInfoV1.urlRequest))
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlInfoV1))
        // swiftlint:disable:next force_unwrapping
        let navActionV1 = MockedNavAction(urlV1!, .other)
        vm.decidePolicy(navActionV1) { policy in
            XCTAssertEqual(policy, .allow)
        }
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlInfoV1.urlRequest))
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV1))
        
        // User taps on a link in web view which already displays some web site
        
        // swiftlint:disable:next force_unwrapping
        let navActionV3 = MockedNavAction(urlV3!, .linkActivated)
        vm.decidePolicy(navActionV3) { policy in
            XCTAssertEqual(policy, .cancel)
        }
        // swiftlint:disable:next force_unwrapping
        let urlDataV3: URLInfo = URLInfo(urlV3!)!
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlDataV3))
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV3!, jsSubject)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlDataV3.urlRequest))
        XCTAssertEqual(vm.state, .viewing(settings, urlDataV3))
    }
    
    func testReload() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, minimumWebViewContext)
        vm.load()
        // swiftlint:disable:next force_unwrapping
        let urlInfoV1: URLInfo = .init(urlV1!)!
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlInfoV1.urlRequest))
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlInfoV1))
        vm.load()
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlInfoV1.urlRequest))
        let errMsg1 = "State should stay the same when wrong action is getting called"
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlInfoV1), errMsg1)
        // swiftlint:disable:next force_unwrapping
        let navActionV1 = MockedNavAction(urlV1!, .other)
        vm.decidePolicy(navActionV1) { policy in
            XCTAssertEqual(policy, .allow)
        }
        
        // User taps on reload before load finish - error in vm state
        vm.reload()
        
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlInfoV1.urlRequest))
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV1))
        
        vm.reload()
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV1))
    }
    
    func testGoBack() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, minimumWebViewContext)
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
        
        // User taps on a link in web view which already displays some web site
        
        // swiftlint:disable:next force_unwrapping
        let navActionV3 = MockedNavAction(urlV3!, .linkActivated)
        vm.decidePolicy(navActionV3) { policy in
            XCTAssertEqual(policy, .cancel)
        }
        // swiftlint:disable:next force_unwrapping
        let urlRequestV3 = URLRequest(url: urlV3!)
        // swiftlint:disable:next force_unwrapping
        let urlDataV3: URLInfo = .init(urlV3!)!
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlDataV3))
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV3!, jsSubject)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV3))
        XCTAssertEqual(vm.state, .viewing(settings, urlDataV3))
        
        // User decided to go back
        
        vm.goBack()
        let msg1 = "Have to finish loading after back navigation"
        XCTAssertNotEqual(vm.state, .viewing(settings, urlInfoV1), msg1)
        XCTAssertNotEqual(vm.state, .waitingForNavigation(settings, urlInfoV1))
        XCTAssertEqual(vm.state, .waitingForNavigation(settings, urlDataV3))
        
        // swiftlint:disable:next force_unwrapping
        let navActionV11 = MockedNavAction(urlV1!, .backForward)
        vm.decidePolicy(navActionV11) { policy in
            XCTAssertEqual(policy, .allow)
        }
        
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV1), "New url is expected")
    }
    
    // swiftlint:disable:next function_body_length
    func testGoForward() throws {
        let vm: WebViewModelImpl = WebViewModelImpl(goodDnsStrategy, exampleSite, minimumWebViewContext)
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
        
        // User taps on a link in web view which already displays some web site
        
        // swiftlint:disable:next force_unwrapping
        let navActionV3 = MockedNavAction(urlV3!, .linkActivated)
        vm.decidePolicy(navActionV3) { policy in
            XCTAssertEqual(policy, .cancel)
        }
        // swiftlint:disable:next force_unwrapping
        let urlRequestV3 = URLRequest(url: urlV3!)
        // swiftlint:disable:next force_unwrapping
        let urlDataV3: URLInfo = .init(urlV3!)!
        XCTAssertEqual(vm.state, .updatingWebView(settings, urlDataV3))
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV3!, jsSubject)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV3))
        XCTAssertEqual(vm.state, .viewing(settings, urlDataV3))
        
        vm.goBack()
        let msg1 = "Have to finish loading after back navigation"
        XCTAssertNotEqual(vm.state, .viewing(settings, urlInfoV1), msg1)
        XCTAssertEqual(vm.state, .waitingForNavigation(settings, urlDataV3))
        
        // swiftlint:disable:next force_unwrapping
        let navActionV11 = MockedNavAction(urlV1!, .backForward)
        vm.decidePolicy(navActionV11) { policy in
            XCTAssertEqual(policy, .allow)
        }
        
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        XCTAssertEqual(vm.state, .viewing(settings, urlInfoV1), "New url is expected")
        
        // User decides to go forward
        
        vm.goForward()
        let msg2 = "Have to finish loading after forward navigation"
        XCTAssertNotEqual(vm.state, .viewing(settings, urlDataV3), msg2)
        XCTAssertEqual(vm.state, .waitingForNavigation(settings, urlInfoV1))
        
        // swiftlint:disable:next force_unwrapping
        let navActionV31 = MockedNavAction(urlV3!, .backForward)
        vm.decidePolicy(navActionV31) { policy in
            XCTAssertEqual(policy, .allow)
        }
        
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV3!, jsSubject)
        XCTAssertEqual(vm.state, .viewing(settings, urlDataV3), "New url is expected")
    }
}
