package org.cotton.browser.content

import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.unit.dp
import org.cotton.browser.content.state.TopSitesUiState
import org.cotton.browser.content.viewmodel.TopSitesViewModel

@Composable
fun TopSitesView(viewModel: TopSitesViewModel) {
    viewModel.load()
    val state = viewModel.uiState.collectAsState(initial = TopSitesUiState.Loading())
    val value = state.value
    val cardSize = 128.dp
    when (value) {
        is TopSitesUiState.Loading -> Text(text = "Loading...")
        is TopSitesUiState.Ready -> {
            LazyVerticalGrid(
                columns = GridCells.Adaptive(minSize = cardSize),
                contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
                userScrollEnabled = false
            ) {
                items(value.sites) { site ->
                    SiteCard(site = site, cardHeight = cardSize) {
                        viewModel.selectSite(site)
                    }
                }
            }
        }
    }
}