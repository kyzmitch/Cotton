package org.cotton.app.servicelocator

import org.cotton.app.db.TabsCacheProvider
import org.cotton.browser.content.data.Tab
import org.cotton.browser.content.service.tab.TabsListManager

class TabsEnvironment {
    companion object {
        val shared: TabsEnvironment = TabsEnvironment()
    }

    /// val cachedTabsManager: TabsListManager

    init {
        val initialTabs = emptyList<Tab>()
        val db = TabsCacheProvider()
        /// cachedTabsManager = TabsListManager(initialTabs, )
    }
}