package org.cotton.app

import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material.MaterialTheme
import androidx.compose.material.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.viewModelFactory
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.flow.drop
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import org.cotton.app.ui.theme.CottonTheme
import org.cotton.browser.content.viewmodel.BrowserContentViewModel
import org.cotton.browser.content.viewmodel.SearchBarViewModel

final class MainActivity : CottonActivity() {
    companion object {
        private const val TAG = "MainActivity"
    }

    private val mainVM: MainBrowserViewModel by viewModels {
        viewModelFactory {
            addInitializer(MainBrowserViewModel::class) {
                MainBrowserViewModel()
            }
        }
    }

    private val searchBarVM: SearchBarViewModel by viewModels {
        viewModelFactory {
            addInitializer(SearchBarViewModel::class) {
                SearchBarViewModel()
            }
        }
    }

    private val browserContentVM: BrowserContentViewModel by viewModels {
        viewModelFactory {
            addInitializer(BrowserContentViewModel::class) {
                BrowserContentViewModel(mainVM.defaultTabContent)
            }
        }
    }

    private val uiScope: CoroutineScope = MainScope()
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            Content(mainVM, searchBarVM, browserContentVM)
        }
        mainVM.route.drop(1).onEach { handleNavigation(it) }.launchIn(uiScope)
    } // on create

    private fun handleNavigation(route: MainBrowserRoute) {
        when (route) {
            MainBrowserRoute.Tabs -> {
                startActivity(Intent(this, TabsActivity::class.java))
            }
            else -> {
                Log.d(Companion.TAG, "handleNavigation: not handlen route")
            }
        }
    }
}

@Composable
internal fun Content(mainVM: MainBrowserViewModel,
                     searchBarVM: SearchBarViewModel,
                     contentVM: BrowserContentViewModel) {
    CottonTheme {
        Surface(
            modifier = Modifier.fillMaxSize(),
            color = MaterialTheme.colors.background
        ) {
            MainBrowserView(mainVM, searchBarVM, contentVM)
        }
    }
}
