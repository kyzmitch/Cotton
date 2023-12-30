package org.cotton.browser.content.service.tab

import org.cotton.browser.content.data.Tab
import org.cotton.browser.content.data.tab.ContentType
import java.util.UUID

interface TabsObserver {
    val tabsObserverName: String
    fun updateTabsCount(tabsCount: Int)
    fun initializeObserver(tabs: List<Tab>)
    fun tabDidAdd(tab: Tab, index: Int)
    fun tabDidSelect(index: Int, contentType: ContentType, identifier: UUID)
    fun tabDidReplace(tab: Tab, index: Int)
}