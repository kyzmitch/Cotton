package org.cotton.browser.content

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material.Button
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier

@Composable
fun TabsCountButton(count: UInt = 0u, onTabsOpen: () -> Unit) {
    Button(
        onClick = onTabsOpen,
        modifier = Modifier.fillMaxSize(),
    ) {
        Text(text = count.toString())
    }
}
