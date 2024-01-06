package org.cotton.app.servicelocator

import android.content.Context
import org.cotton.app.db.TabsResource
import org.cotton.app.strategy.NearbySelectionStrategy
import org.cotton.app.utils.DefaultTabProvider
import org.cotton.browser.content.service.tab.TabsDataService

class TabsEnvironment(context: Context) {
    val tabsDataService: TabsDataService

    companion object {
        @Volatile
        private var shared: TabsEnvironment? = null

        fun getShared(context: Context): TabsEnvironment {
            if (shared == null) {
                synchronized(this) {
                    shared = buildEnvironment(context)
                }
            }
            return shared!!
        }

        private fun buildEnvironment(context: Context): TabsEnvironment {
            return TabsEnvironment(context)
        }
    }

    init {
        val tabsResource = TabsResource(context)
        val defaultProvider = DefaultTabProvider()
        val tabSelectionStrat = NearbySelectionStrategy()
        val tabsAtLogin = tabsResource.tabsFromLastSession()
        tabsDataService = TabsDataService(
            tabsAtLogin,
            tabsResource,
            defaultProvider,
            tabSelectionStrat)
    }
}