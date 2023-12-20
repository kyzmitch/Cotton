package org.cotton.app

import androidx.navigation.NavController
import androidx.navigation.NavGraph.Companion.findStartDestination

class AppNavigationAction(private val navController: NavController) {
    val navigateToMain: () -> Unit = {
        navController.navigate(AppDestinations.MAIN_ROOT) {
            popUpTo(navController.graph.findStartDestination().id) {
                saveState = true
            }
            launchSingleTop = true
            restoreState = true
        }
    }

    val navigateToTabs: () -> Unit = {
        navController.navigate(AppDestinations.TABS) {
            popUpTo(navController.graph.findStartDestination().id) {
                saveState = true
            }
            launchSingleTop = true
            restoreState = true
        }
    }
}