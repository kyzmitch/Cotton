package org.cotton.browser.content.service.tab

import org.cotton.browser.content.data.Tab
import java.util.UUID

/**
 * Tabs DB access protocol which will combine
 * different Dao interfaces under the hood if needed
 * */
interface TabsStoragable {
    /**
     * Fetches the currently selected tab identifier from DB,
     * only single Tab can be selected at a time.
     *
     * @return An identifier of the selected tab
     * */
    fun selectedTabId(): UUID
    /**
     * Adds a completely new tab record to DB
     *
     * @param tab A newly created Tab entity
     * @param select Tells if the newly created Tab object needs to be marked as selected,
     * only single Tab can be selected at a time.
     * */
    fun remember(tab: Tab, select: Boolean)
    /**
     * Fetches all the tabs from the last session (there is no session concept yet)
     * in other words it will give the latest snapshot of synced/cached tabs.
     *
     * @return An immutable list of tabs
     * */
    fun tabsFromLastSession(): List<Tab>
    /**
     * Marks the specific tab as currently selected and deselects previously selected one.
     *
     * @param tab The tab which needs to be selected, only `id` field is needed actually.
     * */
    fun select(tab: Tab)
    /**
     * Removes specific tabs from the DB cache. It doesn't reset the selected tab identifier
     * automatically, because deselection requires additional handling which can't be done
     * on this level (e.g. need to use tab selection strategy)
     *
     * @param tabs A list of tabs which need to be removed from DB tables.
     * A simple list of identifiers would probably be enough to do the job,
     * but this gives more type safety to be sure that identifiers do belong to the tabs.
     * */
    suspend fun forget(tabs: List<Tab>)
    /**
     * Should rewrite the tab content fields if the tab exists in DB tables.
     *
     * @param tab An updated tab.
     * */
    suspend fun update(tab: Tab)
    /**
     * Removes just all tabs
     * */
    suspend fun forgetAll()
}