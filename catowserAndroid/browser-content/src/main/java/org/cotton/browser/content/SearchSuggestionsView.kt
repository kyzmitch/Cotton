package org.cotton.browser.content

import androidx.compose.foundation.layout.padding
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp

@Composable
fun SearchSuggestionsView() {
    Text("Results", modifier = Modifier.padding(8.dp), fontWeight = FontWeight.Bold)
}
