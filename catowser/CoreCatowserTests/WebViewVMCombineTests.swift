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

final class WebViewVMCombineTests: XCTestCase {
    
    let goodServerMock: MockedGoodDnsServer = .init()
    let goodJsonEncodingMock: MockedGoodJSONEncoding = .init()
    // swiftlint:disable:next force_unwrapping
    lazy var goodReachabilityMock: MockedReachabilityAdaptee = .init(server: goodServerMock)!
    lazy var goodDnsClient: HttpKit.Client<MockedGoodDnsServer, MockedReachabilityAdaptee> = {
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
    let minimumWebViewContext: MockedMinimumCombineWebViewContext = .init()
    
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
        let urlRequestV1 = URLRequest(url: urlV1!)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV1))
        // swiftlint:disable:next force_unwrapping
        let wrongUrlRequestV1 = URLRequest(url: wrongUrlV1!)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV1))
        XCTAssertEqual(vm.state, .updatingWebView(urlRequestV1, settings))
        // swiftlint:disable:next force_unwrapping
        vm.finishLoading(urlV1!, jsSubject)
        XCTAssertEqual(vm.combineWebPageState.value, .load(urlRequestV1))
        XCTAssertEqual(vm.state, .viewing(urlRequestV1, settings))
    }
}
