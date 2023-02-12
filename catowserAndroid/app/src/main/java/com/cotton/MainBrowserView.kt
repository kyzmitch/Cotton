package com.cotton

import androidx.compose.foundation.layout.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
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
    // TBD: Move to some view model
    val searchText: String = ""
    val matchesFound: Boolean = false
    val onSearchTextChanged: (String) -> Unit = {}
    val onClearClick: () -> Unit = {}

    Box {
        Column {
            Row {
                SearchBarView(
                    searchText,
                    "Search or enter address",
                    onSearchTextChanged,
                    onClearClick
                )
            }
            Row {
                if (matchesFound) {
                    SearchSuggestionsView()
                } else {
                    val domain = DomainName("opennet.ru")
                    val info = URLInfo(HttpScheme.https, "", null, domain)
                    val settings = Site.Settings()
                    val site = Site(info, settings)
                    val content = TabContentType.SiteContent(site)
                    BrowserContent(content)
                }
            }
        } // column
    } // box
}