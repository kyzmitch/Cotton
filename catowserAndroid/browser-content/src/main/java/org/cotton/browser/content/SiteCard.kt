package org.cotton.browser.content

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.layout.padding
import androidx.compose.material.Card
import androidx.compose.material.ExperimentalMaterialApi
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import org.cotton.base.Site
import org.cotton.browser.content.data.opennetru

@OptIn(ExperimentalMaterialApi::class)
@Composable
fun SiteCard(site: Site, cardHeight: Dp, onTap: () -> Unit) {
    Card(
        onClick = onTap,
        elevation = 5.dp,
        modifier = Modifier
            .fillMaxWidth()
            .padding(5.dp)
            .height(cardHeight)
    ) {
        Row(modifier = Modifier.fillMaxWidth()) {
            AsyncImage(
                model = site.urlInfo.faviconURLFromDomain,
                contentDescription = site.host.rawString
            )
        }
        Row(
            modifier = Modifier
                .fillMaxWidth()
        ) {
            Text(text = site.host.rawString)
        }
    }
}

@Preview(showBackground = true)
@Composable
fun SiteCardPreview() {
    SiteCard(site = Site.opennetru, 128.dp) {
        // onTap
    }
}