package org.cotton.app

import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import org.cotton.browser.content.data.TabContentType

class MainBrowserViewModel: ViewModel() {
    private val _route = MutableStateFlow<MainBrowserRoute>(MainBrowserRoute.Nothing)
    val route: StateFlow<MainBrowserRoute> = _route.asStateFlow()

    val barHeight = 50.dp
    val matchesFound: Boolean = false
    val defaultTapContent: TabContentType
        get() = TabContentType.TopSites()

    fun show(route: MainBrowserRoute) {
        _route.update { _ -> route }
    }
}