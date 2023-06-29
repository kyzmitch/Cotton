package org.cotton.app

import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import org.cotton.browser.content.data.TabContentType

class MainBrowserViewModel: ViewModel() {
    val onOpenTabs: () -> Unit = {}
    val barHeight = 50.dp
    val matchesFound: Boolean = false
    val defaultTapContent: TabContentType
        get() = TabContentType.TopSites()
}