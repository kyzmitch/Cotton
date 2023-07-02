package org.cotton.app

import androidx.compose.foundation.layout.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import org.cotton.browser.content.*
import org.cotton.browser.content.viewmodel.SearchBarViewModel
import org.cotton.browser.content.viewmodel.TopSitesViewModel

@Composable
internal fun MainBrowserView(mainVM: MainBrowserViewModel, searchBarVM: SearchBarViewModel) {
    Column(modifier = Modifier.fillMaxSize()) {
        Row(modifier = Modifier
            .height(mainVM.barHeight)
            .fillMaxWidth()) {
            Column(modifier = Modifier.weight(1f)) {
                SearchBarView(searchBarVM)
            }
            Column(modifier = Modifier
                .width(30.dp)
                .fillMaxHeight(), horizontalAlignment = Alignment.End) {
                TabsCountButton(0u) {
                    mainVM.show(MainBrowserRoute.Tabs)
                }
            }
        }
        Row(modifier = Modifier.fillMaxSize()) {
            if (mainVM.matchesFound) {
                SearchSuggestionsView()
            } else {
                BrowserContent(mainVM.defaultTabContent)
            }
        }
    } // column
}
