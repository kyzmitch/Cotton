package org.cotton.browser.content

import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.tooling.preview.Preview
import org.cotton.browser.content.data.TabContentType
import org.cotton.browser.content.viewmodel.BrowserContentViewModel
import org.cotton.browser.content.viewmodel.TopSitesViewModel

@Composable
fun BrowserContent(viewModel: BrowserContentViewModel) {
    val topSitesVM = TopSitesViewModel()
    val state = viewModel.uiState.collectAsState()
    val value = state.value

    when (value) {
        is TabContentType.Blank -> Text(text = "Blank content")
        is TabContentType.TopSites -> {
            TopSitesView(topSitesVM) { site ->
                viewModel.siteSelected(site)
            }
        }
        is TabContentType.Favorites -> Text(text = "Favorite sites")
        is TabContentType.Homepage -> Text(text = "Home page")
        is TabContentType.SiteContent -> CottonWebView(site = value.site)
    }
}

@Preview(showBackground = true)
@Composable
fun BrowserContentPreview() {
    val viewModel = BrowserContentViewModel(TabContentType.TopSites())
    BrowserContent(viewModel)
}
