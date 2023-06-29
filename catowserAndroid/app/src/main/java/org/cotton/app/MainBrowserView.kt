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
internal fun MainBrowserView(viewModel: MainBrowserViewModel, searchBarViewModel: SearchBarViewModel, topSitesVM: TopSitesViewModel) {
    Column(modifier = Modifier.fillMaxSize()) {
        Row(modifier = Modifier
            .height(viewModel.barHeight)
            .fillMaxWidth()) {
            Column(modifier = Modifier.weight(1f)) {
                SearchBarView(searchBarViewModel)
            }
            Column(modifier = Modifier
                .width(30.dp)
                .fillMaxHeight(), horizontalAlignment = Alignment.End) {
                TabsCountButton(viewModel.onOpenTabs, 0u)
            }
        }
        Row(modifier = Modifier.fillMaxSize()) {
            if (viewModel.matchesFound) {
                SearchSuggestionsView()
            } else {
                BrowserContent(viewModel.defaultTapContent, topSitesVM)
            }
        }
    } // column
}
