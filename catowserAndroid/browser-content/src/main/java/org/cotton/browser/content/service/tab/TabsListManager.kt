package org.cotton.browser.content.service.tab

import kotlinx.coroutines.channels.BufferOverflow
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.consumeAsFlow
import kotlinx.coroutines.flow.last
import org.cotton.browser.content.data.Tab
import org.cotton.browser.content.data.tab.ContentType
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
            private val selectionStrategy: TabSelectionStrategy): IndexSelectionContext, TabsSubject {

    private val tabs: MutableList<Tab>
    private val _selectedTabIdChannel: Channel<UUID> = Channel(1, BufferOverflow.DROP_OLDEST)
    val selectedTabIdFlow: Flow<UUID> = _selectedTabIdChannel.consumeAsFlow()
    private val _tabsCountChannel: Channel<Int> = Channel(1, BufferOverflow.DROP_OLDEST)
    val tabsCountFlow: Flow<Int> = _tabsCountChannel.consumeAsFlow()
    private val tabObservers: MutableList<TabsObserver>

    init {
        tabs = initialTabs.toMutableList()
        tabObservers = mutableListOf()
    }

    // region IndexSelectionContext

    override val collectionLastIndex: Int
        get() {
            // -1 index is not possible because always should be at least 1 tab
            val amount = tabs.size
            // Leaving assert even with unit tests
            // https://stackoverflow.com/a/410198
            assert(amount != 0, { "Tabs amount shouldn't be 0" })
            return amount - 1
        }
    override suspend fun currentlySelectedIndex(): Int {
        require(!tabs.isEmpty()) {
            "Tabs amount shouldn't be 0"
        }
        val currentlySelectedId = _selectedTabIdChannel.receive()
        val index = tabs.indexOfFirst { it.id == currentlySelectedId }
        // tabs collection shouldn't be empty, so,
        // it is safe to return index of 1st element
        if (index == -1) {
            return 0
        }
        return index
    }

    // endregion IndexSelectionContext

    // region TabsSubject

    override suspend fun attach(observer: TabsObserver, notify: Boolean) {
        tabObservers.add(observer)
    }

    override suspend fun detach(observer: TabsObserver) {

    }

    override suspend fun add(tab: Tab) {

    }

    override suspend fun close(tab: Tab) {

    }

    override suspend fun closeAll() {

    }

    override suspend fun select(tab: Tab) {

    }

    override suspend fun replaceSelected(content: ContentType) {

    }

    /**
     * FIXME: But properties in Kotlin shouldn't throw
     * */
    override val tabsCount: Int get() = _tabsCountChannel.tryReceive().getOrThrow()
    override val selectedId: UUID get() = _selectedTabIdChannel.tryReceive().getOrThrow()
    override val allTabs: List<Tab> get() = tabs.toList()

    // endregion TabsSubject
}