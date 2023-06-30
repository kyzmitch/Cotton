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
internal fun MainBrowserView(mainVM: MainBrowserViewModel, searchBarVM: SearchBarViewModel, topSitesVM: TopSitesViewModel) {
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
                TabsCountButton({
                    mainVM.show(MainBrowserRoute.Tabs)
                }, 0u)
            }
        }
        Row(modifier = Modifier.fillMaxSize()) {
            if (mainVM.matchesFound) {
                SearchSuggestionsView()
            } else {
                BrowserContent(mainVM.defaultTapContent, topSitesVM)
            }
        }
    } // column
}
