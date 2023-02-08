package com.cotton

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.material.MaterialTheme
import androidx.compose.material.Surface
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.ae.cotton.ui.theme.CottonTheme
import com.browser.content.SearchBarView
import com.browser.content.BrowserContent
import com.browser.content.TabContentType

class MainActivity : ComponentActivity() {
    private var searchText: String = ""
    private val onSearchTextChanged: (String) -> Unit = {}
    private val onClearClick: () -> Unit = {}
    private var matchesFound: Boolean = false
    private val results: @Composable () -> Unit = {}

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            CottonTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colors.background
                ) {
                    Box {
                        Column(
                            modifier = Modifier
                                .fillMaxSize()
                        ) {
                            SearchBarView(
                                searchText,
                                "Search or enter address",
                                onSearchTextChanged,
                                onClearClick
                            )
                            if (matchesFound) {
                                Text("Results", modifier = Modifier.padding(8.dp), fontWeight = FontWeight.Bold)
                                results()
                            } else {
                                BrowserContent(contentType = TabContentType.Blank())
                            }
                        } // column
                    } // box
                } // surface
            } // cotton theme
        }
    }
}
