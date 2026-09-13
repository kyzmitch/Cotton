//
//  FakeTabsStates.swift
//  CottonTabsTests
//

import CoreBrowser
import CottonTabs

struct FakeTabsStates: TabsStatesInterface {
    var addPosition: AddedTabPosition { get async { .listEnd } }
    var contentState: Tab.ContentType { get async { .blank } }
    var addSpeed: TabAddSpeed { .immediately }
    let defaultSelectedTabId: Tab.ID

    init(defaultSelectedTabId: Tab.ID = Tab.ID()) {
        self.defaultSelectedTabId = defaultSelectedTabId
    }
}
