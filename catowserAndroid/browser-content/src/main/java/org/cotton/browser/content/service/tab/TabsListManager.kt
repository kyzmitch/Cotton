package org.cotton.browser.content.service.tab

import kotlinx.coroutines.channels.BufferOverflow
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.consumeAsFlow
import org.cotton.browser.content.data.Tab
import java.util.UUID

class TabsListManager
constructor(initialTabs: List<Tab>,
            private val storage: TabsStoragableDao,
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