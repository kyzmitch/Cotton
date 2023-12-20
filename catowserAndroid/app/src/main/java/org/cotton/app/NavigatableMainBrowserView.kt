package org.cotton.app

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.navigation.activity
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import org.cotton.app.tabs.TabsActivity
import org.cotton.browser.content.viewmodel.BrowserContentViewModel

@Composable
fun NavigatableMainBrowserView(contentVM: BrowserContentViewModel) {
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
        activity(route = AppDestinations.TABS) {
            this.activityClass = TabsActivity::class
        }
    }
}