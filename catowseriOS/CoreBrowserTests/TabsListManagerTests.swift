//
//  TabsListManagerTests.swift
//  CoreBrowserTests
//
//  Created by Andrei Ermoshin on 4/13/21.
//  Copyright © 2021 andreiermoshin. All rights reserved.
//

import XCTest
import CoreBrowser
import CottonBase

extension UUID {
    static let testId1: UUID = .init(uuid: (1, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1))
    static let testId2: UUID = .init(uuid: (0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1))
    static let notPossibleId: UUID = .init(uuid: (0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1))
}

class TabsListManagerTests: XCTestCase {
    
    let tabsStorageMock: TabsStoragableMock = .init()
    
    let tabsStates: TabsStatesMock = .init()
    
    let selectionStrategyMock: TabSelectionStrategyMock = .init()
    
    let exampleTabId: UUID = .testId1
    let knownTabId: UUID = .testId2
    
    let settings: Site.Settings = .init(isPrivate: false,
                                        blockPopups: true,
                                        isJSEnabled: false,
                                        canLoadPlugins: false)
    
    // swiftlint:disable:next force_try
    let exampleDomainName: DomainName = try! .init(input: "www.example.com")
    // swiftlint:disable:next force_try
    let knownDomainName: DomainName = try! .init(input: "www.known.com")
    lazy var exampleURLInfo: URLInfo = .init(scheme: .https,
                                             path: "foo/bar",
                                             query: nil,
                                             domainName: exampleDomainName,
                                             ipAddress: nil)
    lazy var knownURLInfo: URLInfo = .init(scheme: .https,
                                           path: "bar/bar",
                                           query: nil,
                                           domainName: knownDomainName,
                                           ipAddress: nil)
    
    lazy var exampleSite: Site = .init(urlInfo: exampleURLInfo,
                                       settings: settings,
                                       faviconData: nil,
                                       searchSuggestion: nil,
                                       userSpecifiedTitle: nil)
    
    lazy var knownSite: Site = .init(urlInfo: knownURLInfo,
                                     settings: settings,
                                     faviconData: nil,
                                     searchSuggestion: nil,
                                     userSpecifiedTitle: nil)

    func testFailedInit() throws {
        tabsStates.defaultSelectedTabId = .notPossibleId
        tabsStorageMock.fetchAllTabsThrowableError = TabStorageError.notImplemented

        let tabsMgr: TabsListManager = TabsListManager(storage: tabsStorageMock,
                                                       positioning: tabsStates,
                                                       selectionStrategy: selectionStrategyMock)
        XCTAssertEqual(tabsMgr.tabsCount, 0)
        XCTAssertEqual(tabsMgr.selectedId, .notPossibleId)
        _ = XCTWaiter.wait(for: [expectation(description: "Have to wait for async tabs init from cache")], timeout: 1.1)
        // Not testing `tabsMgr.collectionLastIndex` and `tabsMgr.currentlySelectedIndex`
        // because they would trigger assertion failure with currently used `MockedWithErrorTabsStorage`
        // which doesn't return any initial tabs
        XCTAssertEqual(tabsMgr.fetch(), [])
    }
    
    func testInit() throws {
        let tab1: Tab = .init(contentType: .site(exampleSite), idenifier: exampleTabId)
        let tab2: Tab = .init(contentType: .site(knownSite), idenifier: knownTabId)
        let tabsV1: [Tab] = [tab1, tab2]
        
        tabsStates.defaultSelectedTabId = .notPossibleId
        tabsStorageMock.fetchAllTabsReturnValue = tabsV1
        tabsStorageMock.fetchSelectedTabIdReturnValue = knownTabId
        let tabsMgr: TabsListManager = TabsListManager(storage: tabsStorageMock,
                                                       positioning: tabsStates,
                                                       selectionStrategy: selectionStrategyMock)
        XCTAssertEqual(tabsMgr.tabsCount, 0)
        XCTAssertEqual(tabsMgr.selectedId, .notPossibleId)
        _ = XCTWaiter.wait(for: [expectation(description: "Have to wait for async tabs init from cache")], timeout: 1.1)
        XCTAssertEqual(tabsMgr.selectedId, knownTabId)
        XCTAssertEqual(tabsMgr.tabsCount, tabsV1.count)
        XCTAssertEqual(tabsMgr.fetch(), tabsV1)
        
        // User selects already selected
        
        tabsStorageMock.selectTabReturnValue = .init(value: tab2.id)
        tabsMgr.select(tab: tab2)
        _ = XCTWaiter.wait(for: [expectation(description: "Have to wait for async tabs init from cache")], timeout: 0.1)
        XCTAssertEqual(tabsMgr.selectedId, knownTabId)
        
        tabsStorageMock.selectTabReturnValue = .init(value: tab1.id)
        tabsMgr.select(tab: tab1)
        _ = XCTWaiter.wait(for: [expectation(description: "Have to wait for async tabs init from cache")], timeout: 0.1)
        XCTAssertEqual(tabsMgr.selectedId, exampleTabId)
    }
}
