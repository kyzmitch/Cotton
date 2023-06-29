package org.cotton.app

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.material.MaterialTheme
import androidx.compose.material.Surface
import androidx.compose.ui.Modifier
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.flow.forEach
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import org.cotton.browser.content.viewmodel.SearchBarViewModel
import org.cotton.app.ui.theme.CottonTheme
import org.cotton.browser.content.viewmodel.TopSitesViewModel

class MainActivity : ComponentActivity() {
    private val mainVM = MainBrowserViewModel()
    private val searchBarVM = SearchBarViewModel()
    private val topSitesVM = TopSitesViewModel()
    private val uiScope: CoroutineScope = MainScope()
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
        mainVM.route.onEach {route -> handleNavigation(route)}.launchIn(uiScope)
    } // on create

    private fun handleNavigation(route: MainBrowserRoute) {
        when (route) {
            MainBrowserRoute.Tabs -> startActivity(Intent(this, TabsActivity::class::java))
            else -> {

            }
        }
    }
}
