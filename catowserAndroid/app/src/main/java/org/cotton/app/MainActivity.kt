package org.cotton.app

import android.os.Bundle
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material.MaterialTheme
import androidx.compose.material.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.viewModelFactory
import org.cotton.app.servicelocator.TabsEnvironment
import org.cotton.app.ui.theme.CottonTheme
import org.cotton.app.viewmodel.MainBrowserViewModel
import org.cotton.browser.content.viewmodel.TabsListViewModel
import org.cotton.browser.content.viewmodel.BrowserContentViewModel
import org.cotton.browser.content.viewmodel.SearchBarViewModel

class MainActivity : CottonActivity() {
    companion object {
        private const val TAG = "MainActivity"
    }

    private val mainVM: MainBrowserViewModel by viewModels()

    private val tabsVM: TabsListViewModel by viewModels {
        viewModelFactory {
            addInitializer(TabsListViewModel::class) {
                val dataService = TabsEnvironment.getShared(applicationContext).tabsDataService
                TabsListViewModel(dataService, dataService)
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

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            Content(browserContentVM, tabsVM)
        }
    } // on create
}

@Composable
internal fun Content(
    contentVM: BrowserContentViewModel,
    tabsVM: TabsListViewModel
) {
    CottonTheme {
        Surface(
            modifier = Modifier.fillMaxSize(),
            color = MaterialTheme.colors.background,
        ) {
            NavigatableMainBrowserView(contentVM, tabsVM)
        }
    }
}
