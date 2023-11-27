package org.cotton.browser.content

import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.tooling.preview.Preview
import org.cotton.base.Site
import org.cotton.browser.content.data.TabContentType
import org.cotton.browser.content.data.github
import org.cotton.browser.content.data.opennetru
import org.cotton.browser.content.viewmodel.BrowserContentViewModel

@Composable
fun BrowserScreen(viewModel: BrowserContentViewModel) {
    val tabContent = viewModel.tabContent.collectAsState()
    BrowserContent(tabContent = tabContent.value) { viewModel.selectSite(it) }
}

@Composable
fun BrowserContent(tabContent: TabContentType, onSiteSelect: (Site) -> Unit) {
    when (tabContent) {
        is TabContentType.Blank -> Text(text = "Blank content")
        is TabContentType.TopSites -> {
            val topSites = listOf(Site.opennetru, Site.github)
            TopSitesView(topSites, onSiteSelect)
        }
        is TabContentType.Favorites -> Text(text = "Favorite sites")
        is TabContentType.Homepage -> Text(text = "Home page")
        is TabContentType.SiteContent -> CottonWebView(site = tabContent.site)
    }
}

@Preview(showBackground = true)
@Composable
fun BrowserContentPreview() {
    BrowserContent(TabContentType.TopSites(), onSiteSelect = { _ -> })
}
