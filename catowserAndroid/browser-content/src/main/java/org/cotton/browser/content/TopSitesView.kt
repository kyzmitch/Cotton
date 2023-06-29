package org.cotton.browser.content

import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import org.cotton.base.Site
import org.cotton.browser.content.viewmodel.TopSitesUiState
import org.cotton.browser.content.viewmodel.TopSitesViewModel

@Composable
fun TopSitesView(viewModel: TopSitesViewModel) {
    val state = viewModel.uiState.collectAsState(initial = TopSitesUiState.Loading())
    Text(text = state.value.title)
}