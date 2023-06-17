package com.cotton

import androidx.compose.foundation.layout.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.browser.content.*
import org.cotton.base.Site

@Composable
internal fun MainBrowserView() {
    // TBD: Move to some view model
    val searchText: String = ""
    val matchesFound: Boolean = false
    val onSearchTextChanged: (String) -> Unit = {}
    val onClearClick: () -> Unit = {}
    val onOpenTabs: () -> Unit = {}
    val barHeight = 50.dp

    Column(modifier = Modifier.fillMaxSize()) {
        Row(modifier = Modifier
            .height(barHeight)
            .fillMaxWidth()) {
            Column(modifier = Modifier.weight(1f)) {
                SearchBarView(
                    searchText,
                    "Search or enter address",
                    onSearchTextChanged,
                    onClearClick
                )
            }
            Column(modifier = Modifier
                .width(30.dp)
                .fillMaxHeight(), horizontalAlignment = Alignment.End) {
                TabsCountButton(onOpenTabs, 0u)
            }
        }
        Row(modifier = Modifier.fillMaxSize()) {
            if (matchesFound) {
                SearchSuggestionsView()
            } else {
                val content = TabContentType.SiteContent(Site.opennetru)
                BrowserContent(content)
            }
        }
    } // column
}
