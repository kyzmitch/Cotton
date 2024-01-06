package org.cotton.app

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import org.cotton.app.viewmodel.MainBrowserViewModel
import org.cotton.browser.content.view.BrowserScreen
import org.cotton.browser.content.view.SearchBarView
import org.cotton.browser.content.view.SearchSuggestionsView
import org.cotton.browser.content.TabsCountButton
import org.cotton.browser.content.viewmodel.BrowserContentViewModel
import org.cotton.browser.content.viewmodel.SearchBarViewModel

@Composable
internal fun MainBrowserView(
    contentVM: BrowserContentViewModel,
    onOpenTabs: () -> Unit
) {
    val mainVM: MainBrowserViewModel = viewModel()
    val searchBarVM: SearchBarViewModel = viewModel()

    Column(modifier = Modifier.fillMaxSize()) {
        Row(
            modifier = Modifier
                .height(mainVM.barHeight)
                .fillMaxWidth(),
        ) {
            Column(modifier = Modifier.weight(1f)) {
                SearchBarView(searchBarVM)
            }
            Column(
                modifier = Modifier
                    .width(30.dp)
                    .fillMaxHeight(),
                horizontalAlignment = Alignment.End,
            ) {
                TabsCountButton(count = 0u, onTabsOpen = onOpenTabs)
            }
        }
        Row(modifier = Modifier.fillMaxSize()) {
            if (mainVM.matchesFound) {
                SearchSuggestionsView()
            } else {
                BrowserScreen(contentVM)
            }
        }
    } // column
}
