package org.cotton.browser.content.service.tab

import kotlinx.coroutines.channels.BufferOverflow
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.consumeAsFlow
import org.cotton.browser.content.data.Tab
import org.cotton.browser.content.db.AppSettingsStoragableDao
import org.cotton.browser.content.db.TabsStoragableDao
import java.util.UUID

/**
 * Tabs list manager singleton which implements various interfaces
 * including:
 * - observer
 * - tabs management
 *
 * @property storagable A generic interface for TabsResource which deson't expose any framework
 * @property positioning A generic interface to know how the App wants to handle default states
 * @property selectionStrategy An interface to tell how app wants to handle tab selection
 * */
class TabsListManager
constructor(initialTabs: List<Tab>,
            private val storagable: TabsStoragable,
            private val positioning: TabsStates,
            private val selectionStrategy: TabSelectionStrategy) {

    private val tabs: MutableList<Tab>
    private val _selectedTabIdChannel: Channel<UUID> = Channel(1, BufferOverflow.DROP_OLDEST)
    val selectedTabId: Flow<UUID> = _selectedTabIdChannel.consumeAsFlow()
    private val _tabsCountChannel: Channel<Int> = Channel(1, BufferOverflow.DROP_OLDEST)
    val tabsCount: Flow<Int> = _tabsCountChannel.consumeAsFlow()
    private val tabObservers: MutableList<TabsObserver>

    init {
        tabs = initialTabs.toMutableList()
        tabObservers = mutableListOf()
    }
}