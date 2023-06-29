package org.cotton.browser.content.viewmodel

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import org.cotton.base.Site
import org.cotton.browser.content.data.github
import org.cotton.browser.content.data.opennetru

class TopSitesViewModel: ViewModel() {
    private val _uiState = MutableStateFlow<TopSitesUiState>(TopSitesUiState.Loading())
    val uiState: StateFlow<TopSitesUiState> = _uiState.asStateFlow()

    fun load() {
        _uiState.update { _ -> TopSitesUiState.Ready(listOf(Site.opennetru, Site.github)) }
    }
}