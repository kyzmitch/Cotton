//
//  RecordingTabsObserver.swift
//  CottonTabsTests
//

import CoreBrowser
import CottonTabs
import Foundation

@MainActor
final class RecordingTabsObserver: TabsObserver {
    private(set) var initializedTabs: [CoreBrowser.Tab] = []
    private(set) var tabsCountUpdates: [Int] = []

    func initializeObserver(with tabs: [CoreBrowser.Tab]) async {
        initializedTabs = tabs
    }

    func updateTabsCount(with tabsCount: Int) async {
        tabsCountUpdates.append(tabsCount)
    }
}
