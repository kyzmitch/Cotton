package com.browser.content

import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import com.browser.content.TabContentType

@Composable
fun BrowserContent(contentType: TabContentType) {
    when (contentType) {
        is TabContentType.Blank -> Text(text = "Blank content")
        is TabContentType.TopSites -> Text(text = "Top sites")
        is TabContentType.Favorites -> Text(text = "Favorite sites")
        is TabContentType.Homepage -> Text(text = "Home page")
        is TabContentType.SiteContent -> CottonWebView(site = contentType.site)
    }
}

@Preview(showBackground = true)
@Composable
fun DefaultPreview() {
    BrowserContent(TabContentType.Blank())
}