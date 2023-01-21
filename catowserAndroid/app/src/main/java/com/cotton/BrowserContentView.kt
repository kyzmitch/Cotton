package com.cotton

import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.tooling.preview.Preview
import org.cotton.base.Site

sealed class TabContentType {
    class Blank(): TabContentType()
    // Use `Site` type from KotlinMultiplatform module
    class TopSites(): TabContentType()
    class Favorites(): TabContentType()
    class Homepage(): TabContentType()
    class Site(): TabContentType()
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