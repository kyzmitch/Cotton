package org.cotton.app.tabs

import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import org.cotton.browser.content.TabsListViewModel
import org.cotton.browser.content.data.Tab

@Composable
fun TabsScreen(
    viewModel: TabsListViewModel,
    onSelectTab: () -> Unit = {},
    onClose: () -> Unit = {}
) {
    // val tabs = TabsEnvironment.getShared(context).tabsListManager.allTabs()
    TabsGridView(emptyList(), onSelectTab, onClose)
}


@Composable
private fun TabsGridView(
    state: List<Tab>,
    onSelectTab: () -> Unit = {},
    onClose: () -> Unit = {}
) {
    val cardSize = 128.dp
    LazyVerticalGrid(
        columns = GridCells.Adaptive(minSize = cardSize),
        contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
        userScrollEnabled = false,
    ) {
        items(state) { site ->

        }
    }
}