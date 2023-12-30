package org.cotton.browser.content

import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.tooling.preview.Preview
import org.cotton.base.Site
import org.cotton.browser.content.data.tab.ContentType
import org.cotton.browser.content.data.site.github
import org.cotton.browser.content.data.site.opennetru
import org.cotton.browser.content.viewmodel.BrowserContentViewModel

@Composable
fun BrowserScreen(viewModel: BrowserContentViewModel) {
    val tabContent = viewModel.tabContent.collectAsState()
    BrowserContent(tabContent = tabContent.value) { viewModel.selectSite(it) }
}

@Composable
fun BrowserContent(tabContent: ContentType, onSiteSelect: (Site) -> Unit) {
    when (tabContent) {
        is ContentType.Blank -> Text(text = "Blank content")
        is ContentType.TopSites -> {
            val topSites = listOf(Site.opennetru, Site.github)
            TopSitesView(topSites, onSiteSelect)
        }
        is ContentType.Favorites -> Text(text = "Favorite sites")
        is ContentType.Homepage -> Text(text = "Home page")
        is ContentType.SiteContent -> CottonWebView(site = tabContent.site)
    }
}

@Preview(showBackground = true)
@Composable
fun BrowserContentPreview() {
    BrowserContent(ContentType.TopSites, onSiteSelect = { _ -> })
}
