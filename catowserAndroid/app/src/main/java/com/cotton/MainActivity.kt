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

class MainActivity : ComponentActivity() {
    var searchText: String = ""
    val placeholderText: String = ""
    val onSearchTextChanged: (String) -> Unit = {}
    val onClearClick: () -> Unit = {}
    val onNavigateBack: () -> Unit = {}
    var matchesFound: Boolean = false
    val results: @Composable () -> Unit = {}

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            CottonTheme {
                // A surface container using the 'background' color from the theme
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colors.background
                ) {
                    Box {
                        Column(
                            modifier = Modifier
                                .fillMaxSize()
                        ) {

                            SearchBar(
                                searchText,
                                placeholderText,
                                onSearchTextChanged,
                                onClearClick,
                                onNavigateBack
                            )

                            if (matchesFound) {
                                Text("Results", modifier = Modifier.padding(8.dp), fontWeight = FontWeight.Bold)
                                results()
                            } else {
                                BrowserContent(contentType = TabContentType.Blank())
                            }
                        }

                    }
                }
            }
        }
    }
}
