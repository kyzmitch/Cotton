package org.cotton.browser.content

import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import org.cotton.browser.content.data.TabContentType
import org.cotton.browser.content.viewmodel.TopSitesViewModel

@Composable
fun BrowserContent(contentType: TabContentType) {
    val topSitesVM = TopSitesViewModel()
    when (contentType) {
        is TabContentType.Blank -> Text(text = "Blank content")
        is TabContentType.TopSites -> {
            TopSitesView(topSitesVM)
        }
        is TabContentType.Favorites -> Text(text = "Favorite sites")
        is TabContentType.Homepage -> Text(text = "Home page")
        is TabContentType.SiteContent -> CottonWebView(site = contentType.site)
    }

    // observe for topSitesVM change of selected site or
    // use some Tabs Repository and observe it here
}

@Preview(showBackground = true)
@Composable
fun BrowserContentPreview() {
    BrowserContent(TabContentType.TopSites())
}
