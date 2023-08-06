package org.cotton.browser.content.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import org.cotton.base.Site
import org.cotton.browser.content.data.github
import org.cotton.browser.content.data.opennetru
import org.cotton.browser.content.state.TopSitesUiState

class TopSitesViewModel : ViewModel() {
    private val _uiState = MutableStateFlow<TopSitesUiState>(TopSitesUiState.Loading())
    val uiState: StateFlow<TopSitesUiState> = _uiState.asStateFlow()

    fun load() {
        viewModelScope.launch {
            _uiState.update { _ -> TopSitesUiState.Ready(listOf(Site.opennetru, Site.github)) }
        }
    }

    fun selectSite(site: Site) {
        // TODO: update BrowserContentView
    }
}
