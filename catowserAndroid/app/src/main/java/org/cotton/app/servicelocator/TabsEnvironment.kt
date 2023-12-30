package org.cotton.app.servicelocator

import android.content.Context
import org.cotton.app.db.TabsResource

class TabsEnvironment(context: Context) {
    val tabsResource: TabsResource

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
        tabsResource = TabsResource(context)
    }
}