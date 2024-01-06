package org.cotton.browser.content.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import org.cotton.base.Site
import org.cotton.browser.content.data.tab.ContentType

class BrowserContentViewModel(defaultValue: ContentType) : ViewModel() {
    private val _tabContent: MutableStateFlow<ContentType>
    val tabContent: StateFlow<ContentType>

    init {
        _tabContent = MutableStateFlow(defaultValue)
        tabContent = _tabContent.asStateFlow()
    }

    fun selectSite(site: Site) {
        viewModelScope.launch {
            _tabContent.update { _ -> ContentType.SiteContent(site) }
        }
    }
}
