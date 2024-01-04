package org.cotton.app

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.navigation.activity
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import org.cotton.app.tabs.TabsScreen
import org.cotton.browser.content.TabsListViewModel
import org.cotton.browser.content.viewmodel.BrowserContentViewModel

@Composable
fun NavigatableMainBrowserView(
    contentVM: BrowserContentViewModel,
    tabsVM: TabsListViewModel
) {
    val navController = rememberNavController()
    val navigationActions = remember(navController) {
        AppNavigationAction(navController)
    }

    NavHost(
        navController = navController,
        startDestination = AppDestinations.MAIN_ROOT
    ) {
        composable(route = AppDestinations.MAIN_ROOT) {
            MainBrowserView(contentVM, onOpenTabs = navigationActions.navigateToTabs)
        }
        composable(route = AppDestinations.TABS) {
            TabsScreen(tabsVM, onSelectTab = navigationActions.navigateToMain)
        }
    }
}