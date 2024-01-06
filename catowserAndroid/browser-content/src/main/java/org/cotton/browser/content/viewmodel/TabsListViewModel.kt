package org.cotton.browser.content.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import org.cotton.browser.content.data.Tab
import org.cotton.browser.content.usecase.ReadTabsUseCase
import org.cotton.browser.content.usecase.WriteTabsUseCase

sealed class TabsListState {
    object Loading: TabsListState()
    data class LoadedTabs(val list: List<Tab>): TabsListState()
}

class TabsListViewModel
    constructor(
        private val readTabsUseCase: ReadTabsUseCase,
        private val writeTabsUseCase: WriteTabsUseCase
    ): ViewModel() {
        private val _uxState: MutableStateFlow<TabsListState>
        val uxState: StateFlow<TabsListState>

        init {
            _uxState = MutableStateFlow(TabsListState.Loading)
            uxState = _uxState.asStateFlow()
        }

        fun load() {
            viewModelScope.launch {
                val tabs = readTabsUseCase.allTabs()
                _uxState.update { _ -> TabsListState.LoadedTabs(tabs) }
            }
        }

    fun select(tabIndex: Int) {
        viewModelScope.launch {
            val currentState = _uxState.value
            when (currentState) {
                is TabsListState.LoadedTabs -> {
                    if (tabIndex < 0 || tabIndex >= currentState.list.size) {
                        return@launch
                    }
                    val tab = currentState.list[tabIndex]
                    writeTabsUseCase.select(tab)
                } else -> {
                    return@launch
                }
            }
        }
    }
}