package org.cotton.app.servicelocator

import org.cotton.browser.content.data.Tab

class TabsEnvironment {
    companion object {
        val shared: TabsEnvironment = TabsEnvironment()
    }

    init {
        val initialTabs = emptyList<Tab>()
    }
}