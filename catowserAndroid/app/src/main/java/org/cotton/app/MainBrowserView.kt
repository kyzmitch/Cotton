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
import org.cotton.browser.content.BrowserScreen
import org.cotton.browser.content.SearchBarView
import org.cotton.browser.content.SearchSuggestionsView
import org.cotton.browser.content.TabsCountButton
import org.cotton.browser.content.viewmodel.BrowserContentViewModel
import org.cotton.browser.content.viewmodel.SearchBarViewModel

@Composable
internal fun MainBrowserView(
    mainVM: MainBrowserViewModel,
    searchBarVM: SearchBarViewModel,
    contentVM: BrowserContentViewModel,
) {
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
                TabsCountButton(0u) {
                    mainVM.show(MainBrowserRoute.Tabs)
                }
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
