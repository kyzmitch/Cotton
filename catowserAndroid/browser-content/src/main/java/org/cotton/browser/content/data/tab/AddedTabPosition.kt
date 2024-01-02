package org.cotton.browser.content.data.tab

import android.icu.util.DateInterval
import org.cotton.browser.content.data.Tab
import java.util.UUID

enum class AddedTabPosition {
    LIST_END,
    AFTER_SELECTED,
    ;

    fun addTabTo(tab: Tab, currentTabs: List<Tab>, currentlySelectedId: UUID): Int {
        val newIndex: Int
        when (this) {
            LIST_END -> {
                newIndex = currentTabs.size - 1
            }
            AFTER_SELECTED -> {
                val index = currentTabs.indexOfFirst { it.id == currentlySelectedId }
                if (index == -1) {
                    // no previously selected tab, probably when reset to one tab happened
                    return currentTabs.size - 1
                }
                newIndex = index + 1
            }
        }
        return newIndex
    }
}
