package com.browser.content

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material.Button
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier

@Composable
fun TabsCountButton(onOpenTabs: () -> Unit, count: UInt = 0u) {
    Button(
        onClick = onOpenTabs,
        modifier = Modifier.fillMaxSize()
    ) {
        Text(text = count.toString())
    }
}