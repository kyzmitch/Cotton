package org.cotton.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.material.MaterialTheme
import androidx.compose.material.Surface
import androidx.compose.ui.Modifier
import org.cotton.browser.content.viewmodel.SearchBarViewModel
import org.cotton.app.ui.theme.CottonTheme
import org.cotton.browser.content.viewmodel.TopSitesViewModel

class MainActivity : ComponentActivity() {
    private val mainVM = MainBrowserViewModel()
    private val searchBarVM = SearchBarViewModel()
    private val topSitesVM = TopSitesViewModel()
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        topSitesVM.load()
        setContent {
            CottonTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colors.background
                ) {
                    MainBrowserView(mainVM, searchBarVM, topSitesVM)
                } // surface
            } // cotton theme
        } // set content
    } // on create
}
