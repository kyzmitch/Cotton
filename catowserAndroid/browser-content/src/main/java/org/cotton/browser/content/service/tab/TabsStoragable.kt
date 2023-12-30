package org.cotton.browser.content.service.tab

import org.cotton.browser.content.data.Tab
import java.util.UUID

interface TabsStoragable {
    fun selectedTabId(): UUID
    fun remember(tab: Tab, select: Boolean)
    fun tabsFromLastSession(): List<Tab>
    fun select(tab: Tab)
    suspend fun forget(tabs: List<Tab>)
    suspend fun update(tab: Tab)
}