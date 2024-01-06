package org.cotton.browser.content.view

import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import org.cotton.base.Site
import org.cotton.browser.content.SiteCard

@Composable
fun TopSitesView(state: List<Site>, onSiteSelect: (Site) -> Unit) {
    val cardSize = 128.dp
    LazyVerticalGrid(
        columns = GridCells.Adaptive(minSize = cardSize),
        contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
        userScrollEnabled = false,
    ) {
        items(state) { site ->
            SiteCard(site = site, cardHeight = cardSize) {
                onSiteSelect(site)
            }
        }
    }
}
