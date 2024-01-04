package org.cotton.browser.content

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material.Card
import androidx.compose.material.ExperimentalMaterialApi
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import org.cotton.browser.content.data.Tab

@OptIn(ExperimentalMaterialApi::class)
@Composable
fun TabCard(
    tab: Tab,
    cardHeight: Dp = 128.dp,
    onTap: () -> Unit
) {
    Card(
        onClick = onTap,
        elevation = 5.dp,
        modifier = Modifier
            .fillMaxWidth()
            .padding(5.dp)
            .height(cardHeight),
    ) {
        Row(modifier = Modifier.fillMaxWidth()) {
            val site = tab.site
            if (site == null) {
                Box(Modifier.background(Color.White))
            } else {
                AsyncImage(
                    model = site.urlInfo.faviconURLFromDomain,
                    contentDescription = tab.title,
                )
            }
        }
        Row(
            modifier = Modifier
                .fillMaxWidth(),
        ) {
            Text(text = tab.title)
        }
    }
}