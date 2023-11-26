package org.cotton.browser.content.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import org.cotton.base.Site
import org.cotton.browser.content.data.TabContentType

final class BrowserContentViewModel(private val defaultValue: TabContentType) : ViewModel() {
    private val _uiState = MutableStateFlow<TabContentType>(defaultValue)
    val uiState: StateFlow<TabContentType> = _uiState.asStateFlow()

    fun siteSelected(site: Site) {
        viewModelScope.launch {
            _uiState.update { _ -> TabContentType.SiteContent(site) }
        }
    }
}