package com.cotton

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.material.MaterialTheme
import androidx.compose.material.Surface
import androidx.compose.ui.Modifier
import com.browser.content.SearchBarViewModel
import com.cotton.ui.theme.CottonTheme

class MainActivity : ComponentActivity() {
    private val mainViewModel = MainBrowserViewModel()
    private val searchBarViewModel = SearchBarViewModel()
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            CottonTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colors.background
                ) {
                    MainBrowserView(mainViewModel, searchBarViewModel)
                } // surface
            } // cotton theme
        } // set content
    } // on create
}
