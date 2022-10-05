//
//  WebViewVMTests.swift
//  CoreCatowserTests
//
//  Created by Andrei Ermoshin on 10/3/22.
//  Copyright © 2022 andreiermoshin. All rights reserved.
//

import XCTest
import CoreCatowser
import HttpKit
import CoreHttpKit

final class WebViewVMTests: XCTestCase {
    
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
    let minimumWebViewContext: MockedMinimumWebViewContext = .init()
    
    let settings: Site.Settings = .init(isPrivate: false,
                                        blockPopups: true,
                                        isJSEnabled: true,
                                        canLoadPlugins: true)

    func testInit() throws {
        let initialDN: DomainName = try .init(input: "www.example.com")
        let initialInfo: URLInfo = .init(scheme: .https,
                                         path: "foo/bar",
                                         query: nil,
                                         domainName: initialDN,
                                         ipAddress: nil)
        let initialSite: Site = .init(urlInfo: initialInfo,
                                      settings: settings,
                                      faviconData: nil,
                                      searchSuggestion: nil,
                                      userSpecifiedTitle: nil)
        let vm: WebViewModel = WebViewModelImpl(goodDnsStrategy, initialSite, minimumWebViewContext)
        XCTAssertEqual(vm.host.content, Host.Content.domainname)
        XCTAssertEqual(vm.host.rawString, initialDN.rawString)
    }
}
