package org.cotton.browser.content.service.tab

import org.cotton.browser.content.data.Tab
import org.cotton.browser.content.data.tab.ContentType
import java.util.UUID

interface TabsSubject {
    suspend fun attach(observer: TabsObserver, notify: Boolean)
    suspend fun detach(observer: TabsObserver)
    suspend fun add(tab: Tab)
    suspend fun close(tab: Tab)
    suspend fun closeAll()
    suspend fun select(tab: Tab)
    suspend fun replaceSelected(content: ContentType)
    val tabsCount: Int
    val selectedId: UUID
    val allTabs: Array<Tab>
}