package org.cotton.browser.content.service.tab

import org.cotton.browser.content.data.Tab
import java.util.UUID

typealias TabIndex = Int

interface TabsStoragable {
    @Throws(Exception::class)
    /**
     *  The identifier of selected tab.
     * */
    fun fetchSelectedTabId(): UUID
    @Throws(Exception::class)
    /**
     *  Changes selected tab only if it is presented in storage.
     *
     *  @param tab A tab which needs to be selected, if there is another tab
     *  which was selected before it is deselected.
     * */
    fun select(tab: Tab): UUID
    @Throws(Exception::class)
    /**
     * Loads tabs data from storage.
     *
     * @return All the tabs for the current user account.
     * */
    fun fetchAllTabs(): List<Tab>
    @Throws(Exception::class)
    /**
     *  Adds a tab to storage
     *
     *  @param tab The tab object to be updated. Usually only tab content needs to be updated.
     *  @param select Tells if newly added tab neets to be selected or not.
     * */
    fun add(tab: Tab, select: Boolean): Tab
    @Throws(Exception::class)
    /**
     * Updates tab content
     *
     * @param tab The tab object to be updated. Usually only tab content needs to be updated.
     * */
    fun update(tab: Tab): Tab
    @Throws(Exception::class)
    /**
     * Removes some tabs for current session
     *
     * @param tabs Remove one or more tabs
     * */
    fun remove(tabs: List<Tab>): List<Tab>
}
