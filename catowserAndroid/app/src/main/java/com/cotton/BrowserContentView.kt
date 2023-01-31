package com.cotton

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
    Text(text = "To be implemented using switch over tab content")
}

@Preview(showBackground = true)
@Composable
fun DefaultPreview() {
    BrowserContent(TabContentType.Blank())
}