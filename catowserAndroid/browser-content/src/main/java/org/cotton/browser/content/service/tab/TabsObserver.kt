package org.cotton.browser.content.service.tab

import org.cotton.browser.content.data.Tab
import org.cotton.browser.content.data.tab.ContentType
import java.util.UUID

/**
 * Tabs observer interface (observer design pattern).
 * Notes:
 * - No need to add delegate methods for tab close case, because anyway view must be removed right away.
 * - Tab did remove function is not needed, because we want to remove it from UI right away.
 * @see FutureDirections https://github.com/apple/swift-evolution/blob/main/proposals/0395-observability.md
 * */
interface TabsObserver {
    /**
     * To be able to search specific observer.
     * */
    val tabsObserverName: String
    /**
     * Updates observer with tabs count.
     *
     * @param tabsCount New number of tabs.
     * */
    fun updateTabsCount(tabsCount: Int)
    /**
     * Provide necessary data to render UI on tablets
     *
     * @param tabs Tabs from cache at application start.
     * */
    fun initializeObserver(tabs: List<Tab>)
    /**
     * Tells other observers about new tab.
     * We can pause drawing new tab on view layer
     * to be able firstly determine type of initial tab state.
     * @param tab new tab
     * @param index where to add new object
     * */
    fun tabDidAdd(tab: Tab, index: Int)
    /**
     * Tells observer that index has changed.
     *
     * @param index new selected index.
     * @param content Tab content, e.g. can be site. Need to pass it to allow browser to change content in web view.
     * @param identifier needed to quickly determine visual state (selected view or not)
     * */
    fun tabDidSelect(index: Int, contentType: ContentType, identifier: UUID)
    /**
     * Notifies about tab content type changes or `site` changes
     * @param tab new tab for replacement
     * @param index original tab's index which needs to be replaced
     * */
    fun tabDidReplace(tab: Tab, index: Int)
}