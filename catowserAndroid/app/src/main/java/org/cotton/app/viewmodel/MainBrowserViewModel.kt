package org.cotton.app.viewmodel

import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import org.cotton.browser.content.data.tab.ContentType

class MainBrowserViewModel : ViewModel() {
    val barHeight = 50.dp
    val matchesFound: Boolean = false
    val defaultTabContent: ContentType
        get() = ContentType.TopSites
}
