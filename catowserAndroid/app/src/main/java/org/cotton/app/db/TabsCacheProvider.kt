package org.cotton.app.db

import androidx.room.Insert
import androidx.room.Query
import org.cotton.browser.content.data.Tab
import org.cotton.browser.content.service.tab.TabsStoragable
import java.util.UUID

class TabsCacheProvider: TabsStoragable {
    private val tabsDbResource: TabsResource

    init {
        tabsDbResource = TabsResource()
    }

    // region TabsStoragable

    override fun fetchSelectedTabId(): UUID {
        return UUID.randomUUID()
    }

    override fun select(tab: Tab): UUID {
        return UUID.randomUUID()
    }

    override fun fetchAllTabs(): List<Tab> {
        return emptyList()
    }

    @Insert(entity = Tab::class)
    override fun add(tab: Tab, select: Boolean): Tab {
        return Tab.blank
    }

    override fun update(tab: Tab): Tab {
        return tab
    }

    @Query("DELETE FROM tabs WHERE id in (:tabs)")
    override fun remove(tabs: List<UUID>): List<UUID> {
        return emptyList()
    }

    // endregion TabsStoragable
}