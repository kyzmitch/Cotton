package org.cotton.app

import android.os.Bundle
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material.MaterialTheme
import androidx.compose.material.Surface
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import org.cotton.app.ui.theme.CottonTheme

class TabsActivity : CottonActivity() {
    companion object {
        private const val TAG = "TabsActivity"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            Content()
        } // set content
    }
}

@Composable
internal fun Content() {
    CottonTheme {
        Surface(
            modifier = Modifier.fillMaxSize(),
            color = MaterialTheme.colors.background,
        ) { Text(text = "Tabs") }
    }
}
