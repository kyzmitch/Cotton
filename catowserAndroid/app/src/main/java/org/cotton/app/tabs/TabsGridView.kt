package org.cotton.app.tabs

import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.unit.dp
import org.cotton.browser.content.TabCard
import org.cotton.browser.content.viewmodel.TabsListViewModel
import org.cotton.browser.content.data.Tab
import org.cotton.browser.content.viewmodel.TabsListState

@Composable
fun TabsScreen(
    viewModel: TabsListViewModel,
    onSelectTab: () -> Unit = {},
    onBack: () -> Unit = {}
) {
    val state = viewModel.uxState.collectAsState()
    viewModel.load()
    val stateValue = state.value
    when (stateValue) {
        is TabsListState.Loading -> {
            Text(text = "Loading tabs")
        }
        is TabsListState.LoadedTabs -> {
            TabsGridView(stateValue.list, onSelectTab)
        }
    }
}


@Composable
private fun TabsGridView(
    state: List<Tab>,
    onSelectTab: () -> Unit = {}
) {
    val cardSize = 128.dp
    LazyVerticalGrid(
        columns = GridCells.Adaptive(minSize = cardSize),
        contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
        userScrollEnabled = false,
    ) {
        items(state) { tab ->
            TabCard(tab, cardHeight = cardSize, onTap = onSelectTab)
        }
    }
}