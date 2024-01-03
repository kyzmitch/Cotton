package org.cotton.browser.content.service.tab

import kotlinx.coroutines.channels.BufferOverflow
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.consumeAsFlow
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import org.cotton.browser.content.data.Tab
import org.cotton.browser.content.data.tab.ContentType
import org.cotton.browser.content.data.tab.TabAddSpeed
import java.util.Date
import java.util.UUID
import java.util.concurrent.TimeUnit

/**
 * Tabs list manager singleton which implements various interfaces
 * including:
 * - observer
 * - tabs management
 *
 * @property storage A generic interface for TabsResource which deson't expose any framework
 * @property positioning A generic interface to know how the App wants to handle default states
 * @property selectionStrategy An interface to tell how app wants to handle tab selection
 * */
class TabsListManager
constructor(initialTabs: List<Tab>,
            private val storage: TabsStoragable,
            private val positioning: TabsStates,
            private val selectionStrategy: TabSelectionStrategy): IndexSelectionContext, TabsSubject {

    private val tabs: MutableList<Tab>
    private val _selectedTabIdChannel: Channel<UUID> = Channel(1, BufferOverflow.DROP_OLDEST)
    val selectedTabIdFlow: Flow<UUID> = _selectedTabIdChannel.consumeAsFlow()
    private val _tabsCountChannel: Channel<Int> = Channel(1, BufferOverflow.DROP_OLDEST)
    val tabsCountFlow: Flow<Int> = _tabsCountChannel.consumeAsFlow()
    private val tabObservers: MutableList<TabsObserver>
    private val observersLock: Mutex

    init {
        tabs = initialTabs.toMutableList()
        tabObservers = mutableListOf()
        observersLock = Mutex()
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
        observersLock.withLock {
            tabObservers.add(observer)
        }
        if (!notify) {
            return
        }
        val currentTabs = allTabs()
        observer.updateTabsCount(tabsCount())
        observer.initializeObserver(currentTabs)
        val selectedIdentifier = selectedId()
        if (selectedIdentifier == positioning.defaultSelectedTabId) {
            return
        }
        val selectedTabIndex = currentTabs.indexOfFirst { it.id == selectedIdentifier }
        if (selectedTabIndex == -1) {
            return
        }
        val selectedTab = currentTabs.get(selectedTabIndex)
        observer.tabDidSelect(selectedTabIndex, selectedTab.contentType, selectedTab.id)
    }

    override suspend fun detach(observer: TabsObserver) {
        val name = observer.tabsObserverName
        observersLock.withLock {
            tabObservers.removeAll { it.tabsObserverName == name }
        }
    }

    override suspend fun add(tab: Tab) {
        val positionType = positioning.addPosition
        val newIndex = positionType.addTabTo(tab, allTabs(), selectedId())
        tabs.add(newIndex, tab)
        _tabsCountChannel.send(tabs.size)
        val needsSelect = selectionStrategy.makeTabActiveAfterAdding
        storage.remember(tab, needsSelect)
        handleTabAdded(tab, newIndex, needsSelect)
    }

    override suspend fun close(tab: Tab) {
        storage.forget(listOf(tab))
        handleCachedTabRemove(tab)
    }

    override suspend fun closeAll() {
        val contentState = positioning.contentState
        storage.forgetAll()
        tabs.clear()
        _tabsCountChannel.send(0)
        val anotherTab = Tab(Triple(contentState, UUID.randomUUID(), Date()))
        add(anotherTab)
    }

    override suspend fun select(tab: Tab) {
        storage.select(tab)
        if (selectedId() == tab.id) {
            return
        }
        _selectedTabIdChannel.send(tab.id)
    }

    override suspend fun replaceSelected(content: ContentType) {
        val currentTabs = allTabs()
        val selectedTabIndex = currentTabs.indexOfFirst { it.id == selectedId() }
        if (selectedTabIndex == -1) {
            return
        }
        val selectedTab = currentTabs[selectedTabIndex]
        if (selectedTab.contentType == content) {
            return
        }
        val newTab = selectedTab.copy(Triple(
            content,
            selectedTab.id,
            selectedTab.addedTimestamp))
        storage.update(newTab)
        tabs[selectedTabIndex] = newTab
    }

    override suspend fun tabsCount(): Int {
        return _tabsCountChannel.tryReceive().getOrThrow()
    }

    override suspend fun selectedId(): UUID {
        return _selectedTabIdChannel.tryReceive().getOrThrow()
    }

    override fun allTabs(): List<Tab> {
        return tabs.toList()
    }

    // endregion TabsSubject

    // region Private handlers

    private suspend fun handleTabAdded(tab: Tab, index: Int, select: Boolean) {
        // can select new tab only after adding it
        // this is because corresponding view should be in the list

        val speed = positioning.addSpeed
        when (speed) {
            is TabAddSpeed.Immediately -> {
                observersLock.withLock {
                    tabObservers.forEach { it.tabDidAdd(tab, index) }
                }
                if (select) {
                    _selectedTabIdChannel.send(tab.id)
                }
            }
            is TabAddSpeed.After -> {
                Thread.sleep(speed.interval.toDate)
                observersLock.withLock {
                    tabObservers.forEach { it.tabDidAdd(tab, index) }
                }
                if (select) {
                    _selectedTabIdChannel.send(tab.id)
                }
            }
        }
    }

    private suspend fun handleCachedTabRemove(tab: Tab) {
        // if it is a last tab - replace it with a tab with default content
        // browser can't function without at least one tab
        // so, this is kind of a side effect of removing the only one last tab
        val currentTabs = allTabs()
        if (currentTabs.size == 1) {
            tabs.clear()
            _tabsCountChannel.send(0)
            val contentState = positioning.contentState
            val anotherTab = Tab(Triple(contentState, UUID.randomUUID(), Date()))
            add(anotherTab)
        } else {
            val closedTabIndex = tabs.indexOfFirst { it.id == tab.id }
            if (closedTabIndex == -1) {
                require(closedTabIndex != -1) {
                    "Closing non existing tab"
                }
                return
            }

            val newIndex = selectionStrategy.autoSelectedIndexAfterTabRemove(this, closedTabIndex)
            // need to remove it before changing selected index
            // otherwise in one case the handler will select closed tab
            tabs.removeAt(closedTabIndex)
            _tabsCountChannel.send(tabs.size)
            val selectedTab = tabs.getOrNull(newIndex)
            if (selectedTab == null) {
                require(selectedTab != null) {
                    "Failed to find new selected tab"
                }
                return
            }
            _selectedTabIdChannel.send(selectedTab.id)
        }
    }

    // endregion Private handlers
}