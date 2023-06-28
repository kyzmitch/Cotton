package org.cotton.browser.content

import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import org.cotton.base.Site
import org.cotton.browser.content.viewmodel.TopSitesViewModel

@Composable
fun TopSitesView(viewModel: TopSitesViewModel) {
    // viewModel.uiState.
    Text(text = "Top sites")
}