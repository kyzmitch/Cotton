package com.cotton

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.runtime.Composable
import com.browser.content.BrowserContent
import com.browser.content.SearchBarView
import com.browser.content.SearchSuggestionsView
import com.browser.content.TabContentType
import org.cotton.base.DomainName
import org.cotton.base.HttpScheme
import org.cotton.base.Site
import org.cotton.base.URLInfo

@Composable
internal fun MainBrowserView() {
    val searchText: String = ""
    val matchesFound: Boolean = false
    val onSearchTextChanged: (String) -> Unit = {}
    val onClearClick: () -> Unit = {}

    Box {
        Column {
            SearchBarView(
                searchText,
                "Search or enter address",
                onSearchTextChanged,
                onClearClick
            )
            if (matchesFound) {
                SearchSuggestionsView()
            } else {
                val domain = DomainName("opennet.ru")
                val info = URLInfo(HttpScheme.https, "", null, domain)
                val settings = Site.Settings()
                val site = Site(info, settings)
                val content = TabContentType.SiteContent(site)
                BrowserContent(contentType = content)
            }
        } // column
    } // box
}