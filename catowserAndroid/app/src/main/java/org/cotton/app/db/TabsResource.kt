package org.cotton.app.db

import android.content.Context

class TabsResource(private val context: Context) {
    private val tabsDbClient by lazy {
        TabsDBClient.getDatabase(context).tabsDao()
    }
    private val appSettingsDbClient by lazy {
        TabsDBClient.getDatabase(context).appSettingsDao()
    }
}