package org.cotton.browser.content.service.tab

import org.cotton.browser.content.data.Tab
import org.cotton.browser.content.data.TabContentType
import java.util.UUID

interface TabsSubject {
    suspend fun attach(observer: TabsObserver, notify: Boolean)
    suspend fun detach(observer: TabsObserver)
    suspend fun add(tab: Tab)
    suspend fun close(tab: Tab)
    suspend fun closeAll()
    suspend fun select(tab: Tab)
    suspend fun replaceSelected(content: TabContentType)
    val tabsCount: Int
    val selectedId: UUID
    val allTabs: Array<Tab>
}