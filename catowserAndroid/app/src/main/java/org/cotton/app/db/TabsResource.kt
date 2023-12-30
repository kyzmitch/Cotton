package org.cotton.app.db

import android.content.Context
import org.cotton.browser.content.data.Tab
import org.cotton.browser.content.service.tab.TabsStoragable
import java.util.UUID

class TabsResource(private val context: Context): TabsStoragable {
    private val tabsDbClient by lazy {
        TabsDBClient.getDatabase(context).tabsDao()
    }
    private val appSettingsDbClient by lazy {
        TabsDBClient.getDatabase(context).appSettingsDao()
    }

    /**
     * Gets an identifier of a selected tab or an error if no tab is present
     * which isn't possible at least blank tab should be present.
     * */
    override fun selectedTabId(): UUID {
        return appSettingsDbClient.fetchSelectedTabId()
    }

    override fun remember(tab: Tab, select: Boolean) {
        tabsDbClient.add(tab)
        appSettingsDbClient.select(tab.id)
    }

    /**
     * Gets all tabs recorded in DB. Currently there is only one session, but later
     * it should be possible to store and read tabs from different sessions like
     * private browser session tabs & usual tabs.
     * */
    override fun tabsFromLastSession(): List<Tab> {
        return tabsDbClient.fetchAllTabs()
    }

    /**
     * Remembers tab identifier as selected one
     * */
    override fun select(tab: Tab) {
        appSettingsDbClient.select(tab.id)
    }

    /**
     * Forgets specific tabs.
     * If one of removed tabs was selected, then
     * it is not really possible to handle that on this level,
     * because if you deselect the tab, then need to select
     * something new which is unknown and can be based on
     * selection strategy on the upper level.
     * */
    override suspend fun forget(tabs: List<Tab>) {
        val identifiers = tabs.map {it.id }
        tabsDbClient.remove(identifiers)
    }

    override suspend fun update(tab: Tab) {
        tabsDbClient.update(tab)
    }
}