package org.cotton.app

import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel

class MainBrowserViewModel: ViewModel() {
    val onOpenTabs: () -> Unit = {}
    val barHeight = 50.dp
    val matchesFound: Boolean = false
}