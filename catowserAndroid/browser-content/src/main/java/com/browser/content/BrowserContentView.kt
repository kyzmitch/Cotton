package com.browser.content

import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import org.cotton.base.Site

sealed class TabContentType {
    class Blank(): TabContentType()
    class TopSites(): TabContentType()
    class Favorites(): TabContentType()
    class Homepage(): TabContentType()
    class SiteContent(val site: Site): TabContentType()
}

@Composable
fun BrowserContent(contentType: TabContentType) {
    when (contentType) {
        is TabContentType.Blank -> Text(text = "Blank content")
        is TabContentType.TopSites -> Text(text = "Top sites")
        is TabContentType.Favorites -> Text(text = "Favorite sites")
        is TabContentType.Homepage -> Text(text = "Home page")
        is TabContentType.SiteContent -> Text(text = contentType.site.searchBarContent)
    }
}

@Preview(showBackground = true)
@Composable
fun DefaultPreview() {
    BrowserContent(TabContentType.Blank())
}