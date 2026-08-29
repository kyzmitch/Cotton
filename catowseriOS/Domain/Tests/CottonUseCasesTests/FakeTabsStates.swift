//
//  FakeTabsStates.swift
//  CottonUseCasesTests
//

import CoreBrowser
import CottonTabs

struct FakeTabsStates: TabsStatesInterface {
    var addPosition: AddedTabPosition { get async { .listEnd } }
    var contentState: Tab.ContentType { get async { .blank } }
    var addSpeed: TabAddSpeed { .immediately }
    var defaultSelectedTabId: Tab.ID { Tab.ID() }
}
