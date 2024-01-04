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
import org.cotton.browser.content.usecase.ReadTabsUseCase
import org.cotton.browser.content.usecase.WriteTabsUseCase
import java.util.Date
import java.util.UUID

/**
 * Tabs list manager singleton which implements various interfaces
 * including:
 * - observer
 * - tabs management
 *
 * In android architecture it is probably right to call it as a TabsUseCase,
 * but not sure which class will have a role of observer after that.
 * A use case shouldn't store any state, and observer should have the state.
 * https://developer.android.com/topic/architecture#domain-layer
 *
 * @property tabsRepository A generic interface for TabsResource which deson't expose any framework
 * @property positioning A generic interface to know how the App wants to handle default states
 * @property selectionStrategy An interface to tell how app wants to handle tab selection
 * */
class TabsListManager
constructor(initialTabs: List<Tab>,
            private val tabsRepository: TabsRepository,
            private val positioning: TabsStates,
            private val selectionStrategy: TabSelectionStrategy):
    IndexSelectionContext,
    TabsSubject,
    ReadTabsUseCase,
    WriteTabsUseCase {

    private val tabs: MutableList<Tab>
    private val _selectedTabIdChannel: Channel<UUID> = Channel(1, BufferOverflow.DROP_OLDEST)
    val selectedTabIdFlow: Flow<UUID> = _selectedTabIdChannel.consumeAsFlow()
    private val _tabsCountChannel: Channel<Int> = Channel(1, BufferOverflow.DROP_OLDEST)
    val tabsCountFlow: Flow<Int> = _tabsCountChannel.consumeAsFlow()
    private val tabObservers: MutableList<TabsObserver>
    private val observersLock: Mutex
    private val tabsLock: Mutex

    init {
        tabs = initialTabs.toMutableList()
        tabObservers = mutableListOf()
        observersLock = Mutex()
        tabsLock = Mutex()
    }

    // region IndexSelectionContext

    override suspend fun collectionLastIndex(): Int {
        // -1 index is not possible because always should be at least 1 tab
        var amount: Int = 0
        tabsLock.withLock {
            amount = tabs.size
        }
        require(amount != 0) {
            "Tabs amount shouldn't be 0"
        }
        return amount - 1
    }

    override suspend fun currentlySelectedIndex(): Int {
        val currentlySelectedId = _selectedTabIdChannel.receive()
        var index: Int = 0
        tabsLock.withLock {
            require(!tabs.isEmpty()) {
                "Tabs amount shouldn't be 0"
            }
            index = tabs.indexOfFirst { it.id == currentlySelectedId }
        }
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
        /// Maybe not very optimal to create a huge copy of all tabs
        /// not all of them are needed to display by the observer right away
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
        var tabsCount: Int = 0
        tabsLock.withLock {
            tabs.add(newIndex, tab)
            tabsCount = tabs.size
        }
        _tabsCountChannel.send(tabsCount)
        val needsSelect = selectionStrategy.makeTabActiveAfterAdding
        tabsRepository.remember(tab, needsSelect)
        handleTabAdded(tab, newIndex, needsSelect)
    }

    override suspend fun close(tab: Tab) {
        tabsRepository.forget(tab)
        handleCachedTabRemove(tab)
    }

    override suspend fun closeAll() {
        val contentState = positioning.contentState
        tabsRepository.forgetAll()
        tabsLock.withLock {
            tabs.clear()
        }
        _tabsCountChannel.send(0)
        val anotherTab = Tab(Triple(contentState, UUID.randomUUID(), Date()))
        add(anotherTab)
    }

    override suspend fun select(tab: Tab) {
        tabsRepository.select(tab)
        if (selectedId() == tab.id) {
            return
        }
        _selectedTabIdChannel.send(tab.id)
    }

    override suspend fun replaceSelected(content: ContentType) {
        var selectedTabIndex: Int = -1
        var selectedTab: Tab? = null
        var updatedSelectedTab: Tab? = null
        tabsLock.withLock {
            selectedTabIndex = tabs.indexOfFirst { it.id == selectedId() }
            if (selectedTabIndex == -1) {
                return
            }
            selectedTab = tabs[selectedTabIndex]
            /// Next logic doesn't need to be in the lock
            /// but the last line below is still needed to be protected
            /// so that, it is better to lock once vs twice
            val constantTab = selectedTab
            if (constantTab == null) {
                return
            }
            if (constantTab.contentType == content) {
                return
            }
            val newTab = constantTab.copy(Triple(
                content,
                constantTab.id,
                constantTab.addedTimestamp))
            tabs[selectedTabIndex] = newTab
            updatedSelectedTab = newTab
        }
        val updatedTab = updatedSelectedTab
        if (updatedTab == null) {
            return
        }
        tabsRepository.update(updatedTab)
    }

    override suspend fun tabsCount(): Int {
        return _tabsCountChannel.tryReceive().getOrThrow()
    }

    override suspend fun selectedId(): UUID {
        return _selectedTabIdChannel.tryReceive().getOrThrow()
    }

    override suspend fun allTabs(): List<Tab> {
        tabsLock.withLock {
            return tabs.toList()
        }
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
        tabsLock.lock(this)
        val tabsCount = tabs.size
        if (tabsCount == 1) {
            tabs.clear()
            tabsLock.unlock(this)
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
            val selectedTab = tabs.getOrNull(newIndex)
            tabsLock.unlock(this)
            _tabsCountChannel.send(tabs.size)
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